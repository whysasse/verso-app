import SwiftUI

enum VersoAnimation {
    static let fast:    Animation = .easeOut(duration: 0.15)
    static let normal:  Animation = .easeInOut(duration: 0.25)
    static let slow:    Animation = .spring(response: 0.4, dampingFraction: 0.75)
    static let spinner: Animation = .linear(duration: 0.8).repeatForever(autoreverses: false)
}
