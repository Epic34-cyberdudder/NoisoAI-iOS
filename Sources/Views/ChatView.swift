import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showingSettings = false
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.12, blue: 0.08)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    HStack {
                                        if message.role == "user" { Spacer() }
                                        
                                        Text(message.content)
                                            .padding(12)
                                            .background(message.role == "user" ? Color(red: 0.2, green: 0.25, blue: 0.15) : Color(red: 0.15, green: 0.18, blue: 0.12))
                                            .foregroundColor(.white)
                                            .cornerRadius(16)
                                        
                                        if message.role != "user" { Spacer() }
                                    }
                                    .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            if let lastID = viewModel.messages.last?.id {
                                proxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                            .padding(.vertical, 4)
                    }
                    
                    HStack(spacing: 12) {
                        TextField("Ask NoiosoAI...", text: $viewModel.inputText)
                            .padding(14)
                            .background(Color(red: 0.15, green: 0.17, blue: 0.11))
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .disabled(viewModel.isLoading)
                            .onSubmit {
                                Task { await viewModel.sendMessage() }
                            }

                        Button(action: {
                            Task { await viewModel.sendMessage() }
                        }) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 40, height: 40)
                                .background(Color(red: 0.25, green: 0.28, blue: 0.18))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.isLoading || viewModel.inputText.isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.08, green: 0.1, blue: 0.06).opacity(0.9))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("NoiosoAI")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.9, green: 0.85, blue: 0.5))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingClearConfirmation = true
                        }) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(Color(red: 0.9, green: 0.85, blue: 0.5))
                        }
                        .confirmationDialog(
                            "Clear the entire conversation?",
                            isPresented: $showingClearConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("Clear Chat", role: .destructive) {
                                viewModel.clearChat()
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                        
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Color(red: 0.9, green: 0.85, blue: 0.5))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}