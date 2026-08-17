import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false

    private let apiService = OllamaApiService.shared
    private let settings = SettingsManager.shared
    private let messagesKey = "chatMessages"

    init() {
        loadMessages()
    }

    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(role: "user", content: inputText)
        messages.append(userMessage)
        inputText = ""
        saveMessages()

        isLoading = true

        let assistantMessage = ChatMessage(role: "assistant", content: "")
        messages.append(assistantMessage)
        let assistantIndex = messages.count - 1

        do {
            let history = Array(messages.dropLast()) // everything up to and including the user's message
            let stream = apiService.streamMessage(host: settings.hostUrl, model: settings.selectedModel, messages: history)
            for try await chunk in stream {
                messages[assistantIndex].content += chunk
            }
            if messages[assistantIndex].content.isEmpty {
                messages[assistantIndex].content = "(No response from the model)"
            }
        } catch {
            messages[assistantIndex].content = "Error: \(error.localizedDescription)"
        }

        isLoading = false
        saveMessages()
    }

    func clearChat() {
        messages.removeAll()
        saveMessages()
    }

    private func loadMessages() {
        guard let data = UserDefaults.standard.data(forKey: messagesKey),
              let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) else { return }
        messages = decoded
    }

    private func saveMessages() {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        UserDefaults.standard.set(data, forKey: messagesKey)
    }
}
