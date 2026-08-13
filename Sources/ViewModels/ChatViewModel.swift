import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    
    private let apiService = OllamaApiService.shared
    private let settings = SettingsManager.shared
    
    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(role: "user", content: inputText)
        messages.append(userMessage)
        
        inputText = ""
        isLoading = true
        
        do {
            let replyText = try await apiService.sendMessage(
                host: settings.hostUrl,
                model: settings.selectedModel,
                messages: messages
            )
            let assistantMessage = ChatMessage(role: "assistant", content: replyText)
            messages.append(assistantMessage)
        } catch {
            let errorMessage = ChatMessage(role: "assistant", content: "Error: \(error.localizedDescription)")
            messages.append(errorMessage)
        }
        
        isLoading = false
    }
}