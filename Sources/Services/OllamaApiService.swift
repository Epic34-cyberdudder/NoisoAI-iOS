import Foundation

struct OllamaRequest: Codable {
    let model: String
    let messages: [APIMessage]
    let stream: Bool
}

struct APIMessage: Codable {
    let role: String
    let content: String
}

struct OllamaResponse: Codable {
    let message: APIMessage
}

class OllamaApiService {
    static let shared = OllamaApiService()
    
    func sendMessage(host: String, model: String, messages: [ChatMessage]) async throws -> String {
        guard let url = URL(string: "\(host.trimmingCharacters(in: .init(charactersIn: "/")))/api/chat") else {
            throw URLError(.badURL)
        }
        
        let apiMessages = messages.map { APIMessage(role: $0.role, content: $0.content) }
        let requestBody = OllamaRequest(model: model, messages: apiMessages, stream: false)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(OllamaResponse.self, from: data)
        return decodedResponse.message.content
    }
}