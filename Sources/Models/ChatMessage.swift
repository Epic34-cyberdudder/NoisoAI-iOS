import Foundation

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let role: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case role, content
    }
}