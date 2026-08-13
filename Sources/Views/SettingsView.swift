import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ollama Configuration")) {
                    TextField("Host URL", text: $settings.hostUrl)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Model Name (e.g. llama3)", text: $settings.selectedModel)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}