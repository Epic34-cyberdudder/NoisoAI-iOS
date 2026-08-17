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

struct OllamaStreamChunk: Codable {
    let message: APIMessage?
    let done: Bool
}

struct OllamaTagsResponse: Codable {
    let models: [OllamaModelInfo]
}

struct OllamaModelInfo: Codable {
    let name: String
}

enum OllamaError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The Ollama host URL is invalid or empty. Check it in Settings."
        case .invalidResponse:
            return "Received an unexpected response from the Ollama server."
        case .serverError(let statusCode, let message):
            let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty
                ? "Ollama server returned an error (status \(statusCode))."
                : "Ollama server error (\(statusCode)): \(trimmed)"
        }
    }
}

class OllamaApiService {
    static let shared = OllamaApiService()

    /// Local inference on modest hardware (README recommends as little as a
    /// 2-4 thread CPU) can take a while, so this is far more generous than
    /// URLSession's 60s default.
    private static let requestTimeout: TimeInterval = 300

    private func baseURL(for host: String) throws -> String {
        let trimmed = host.trimmingCharacters(in: .init(charactersIn: "/"))
        guard !trimmed.isEmpty else { throw OllamaError.invalidURL }
        return trimmed
    }

    /// Streams reply tokens from Ollama's `/api/chat` endpoint as they're generated.
    func streamMessage(host: String, model: String, messages: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let base = try baseURL(for: host)
                    guard let url = URL(string: "\(base)/api/chat") else {
                        throw OllamaError.invalidURL
                    }

                    let apiMessages = messages.map { APIMessage(role: $0.role, content: $0.content) }
                    let requestBody = OllamaRequest(model: model, messages: apiMessages, stream: true)

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = try JSONEncoder().encode(requestBody)
                    request.timeoutInterval = Self.requestTimeout

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw OllamaError.invalidResponse
                    }

                    guard httpResponse.statusCode == 200 else {
                        var body = ""
                        for try await line in bytes.lines { body += line }
                        throw OllamaError.serverError(statusCode: httpResponse.statusCode, message: body)
                    }

                    for try await line in bytes.lines {
                        guard !line.isEmpty, let data = line.data(using: .utf8) else { continue }
                        let chunk = try JSONDecoder().decode(OllamaStreamChunk.self, from: data)
                        if let content = chunk.message?.content, !content.isEmpty {
                            continuation.yield(content)
                        }
                        if chunk.done { break }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Lightweight connectivity check used by the Settings screen's "Test Connection" button.
    /// Returns the names of models available on the server.
    func testConnection(host: String) async throws -> [String] {
        let base = try baseURL(for: host)
        guard let url = URL(string: "\(base)/api/tags") else {
            throw OllamaError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OllamaError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw OllamaError.serverError(statusCode: httpResponse.statusCode, message: String(data: data, encoding: .utf8) ?? "")
        }

        let decoded = try JSONDecoder().decode(OllamaTagsResponse.self, from: data)
        return decoded.models.map { $0.name }
    }
}
