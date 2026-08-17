import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var hostUrl: String {
        didSet { UserDefaults.standard.set(hostUrl, forKey: "hostUrl") }
    }
    
    @Published var selectedModel: String {
        didSet { UserDefaults.standard.set(selectedModel, forKey: "selectedModel") }
    }
    
    init() {
        // Left blank by default rather than "localhost" - on a phone, localhost
        // means the phone itself, not the PC running Ollama, which is a
        // confusing trap for first-time setup.
        self.hostUrl = UserDefaults.standard.string(forKey: "hostUrl") ?? ""
        self.selectedModel = UserDefaults.standard.string(forKey: "selectedModel") ?? "llama3.2:1b"
    }
}