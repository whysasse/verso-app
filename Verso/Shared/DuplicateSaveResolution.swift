import Foundation

/// How the user resolved a duplicate URL when saving from the Share extension or in-app add flow.
enum DuplicateSaveResolution: Equatable, Codable {
    /// Overwrite the Markdown file at this path (must stay under the Verso library folder).
    case replaceExisting(path: String)
    /// Save as a new file; the article title should already include the copy suffix where needed.
    case saveCopy

    private enum CodingKeys: String, CodingKey {
        case kind
        case path
    }

    private enum Kind: String, Codable {
        case replaceExisting
        case saveCopy
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
        case .replaceExisting:
            let path = try c.decode(String.self, forKey: .path)
            self = .replaceExisting(path: path)
        case .saveCopy:
            self = .saveCopy
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .replaceExisting(let path):
            try c.encode(Kind.replaceExisting, forKey: .kind)
            try c.encode(path, forKey: .path)
        case .saveCopy:
            try c.encode(Kind.saveCopy, forKey: .kind)
        }
    }
}
