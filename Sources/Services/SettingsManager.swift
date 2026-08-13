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
        self.hostUrl = UserDefaults.standard.string(forKey: "hostUrl") ?? "http://localhost:11434"
        self.selectedModel = UserDefaults.standard.string(forKey: "selectedModel") ?? "llama3"
    }
}