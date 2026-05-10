import AVFoundation
import Combine

enum TTSSpeed: Float, CaseIterable {
    case slow = 0.75
    case normal = 1.0
    case fast = 1.5

    var label: String {
        switch self {
        case .slow: return "0.75×"
        case .normal: return "1×"
        case .fast: return "1.5×"
        }
    }

    func next() -> TTSSpeed {
        let all = TTSSpeed.allCases
        let idx = all.firstIndex(of: self)!
        return all[(idx + 1) % all.count]
    }

    // AVSpeechUtteranceDefaultSpeechRate is ~0.5; map relative speeds to AVFoundation range
    var avRate: Float {
        AVSpeechUtteranceDefaultSpeechRate * rawValue
    }
}

final class TTSService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentParagraphIndex: Int = 0
    @Published var speed: TTSSpeed {
        didSet { UserDefaults.standard.set(speed.rawValue, forKey: "tts.speed") }
    }

    private let synthesizer = AVSpeechSynthesizer()
    private var paragraphs: [String] = []

    override init() {
        let saved = UserDefaults.standard.float(forKey: "tts.speed")
        speed = TTSSpeed(rawValue: saved) ?? .normal
        super.init()
        synthesizer.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
    }

    func start(paragraphs: [String], from index: Int = 0) {
        self.paragraphs = paragraphs
        currentParagraphIndex = index
        speak(at: index)
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
        isPlaying = false
    }

    func resume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            isPlaying = true
        } else {
            speak(at: currentParagraphIndex)
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        currentParagraphIndex = 0
        paragraphs = []
    }

    func skipForward() {
        guard currentParagraphIndex + 1 < paragraphs.count else { return }
        synthesizer.stopSpeaking(at: .immediate)
        currentParagraphIndex += 1
        speak(at: currentParagraphIndex)
    }

    func skipBack() {
        let target = max(0, currentParagraphIndex - 1)
        synthesizer.stopSpeaking(at: .immediate)
        currentParagraphIndex = target
        speak(at: currentParagraphIndex)
    }

    func cycleSpeed() {
        speed = speed.next()
        if isPlaying {
            // Restart current paragraph at new speed
            let idx = currentParagraphIndex
            synthesizer.stopSpeaking(at: .immediate)
            speak(at: idx)
        }
    }

    // MARK: - Private

    private func speak(at index: Int) {
        guard index < paragraphs.count, !paragraphs[index].trimmingCharacters(in: .whitespaces).isEmpty else {
            advanceOrStop(from: index)
            return
        }
        let utterance = AVSpeechUtterance(string: paragraphs[index])
        utterance.rate = speed.avRate
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.language.languageCode?.identifier ?? "en")
        synthesizer.speak(utterance)
        isPlaying = true
    }

    private func advanceOrStop(from index: Int) {
        let next = index + 1
        if next < paragraphs.count {
            currentParagraphIndex = next
            speak(at: next)
        } else {
            isPlaying = false
        }
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.advanceOrStop(from: self.currentParagraphIndex)
        }
    }
}
