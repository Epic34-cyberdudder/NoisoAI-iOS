import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @Environment(\.presentationMode) var presentationMode

    @State private var isTesting = false
    @State private var testResultMessage: String?
    @State private var testSucceeded = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ollama Configuration")) {
                    TextField("e.g. 192.168.1.5:11434", text: $settings.hostUrl)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)

                    TextField("Model Name (e.g. llama3.2:1b)", text: $settings.selectedModel)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Section {
                    Button(action: testConnection) {
                        HStack {
                            Text("Test Connection")
                            if isTesting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isTesting || settings.hostUrl.trimmingCharacters(in: .whitespaces).isEmpty)

                    if let message = testResultMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundColor(testSucceeded ? .green : .red)
                    }
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

    private func testConnection() {
        isTesting = true
        testResultMessage = nil

        Task {
            do {
                let models = try await OllamaApiService.shared.testConnection(host: settings.hostUrl)
                testSucceeded = true
                testResultMessage = models.isEmpty
                    ? "Connected, but no models are pulled yet on the server."
                    : "Connected! \(models.count) model(s) available: \(models.joined(separator: ", "))"
            } catch {
                testSucceeded = false
                testResultMessage = error.localizedDescription
            }
            isTesting = false
        }
    }
}
