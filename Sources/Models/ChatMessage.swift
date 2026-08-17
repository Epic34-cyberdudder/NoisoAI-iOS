import Foundation

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let role: String
    var content: String

    enum CodingKeys: String, CodingKey {
        case role, content
    }
}