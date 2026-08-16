import SwiftUI

struct AICoachView: View {
    @StateObject private var manager = AICoachManager.shared
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Chat Listesi
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // "Son Antrenmanımı Analiz Et" Hızlı Butonu
                                if !SessionStore.shared.sessions.isEmpty {
                                    Button(action: {
                                        manager.analyzeLatestSession()
                                        // Scroll down
                                        if let lastId = manager.messages.last?.id {
                                            withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "sparkles")
                                            Text("Son Antrenmanımı Analiz Et")
                                        }
                                        .font(.caption).fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .cornerRadius(20)
                                    }
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                                }
                                
                                // Mesajlar
                                ForEach(manager.messages) { msg in
                                    MessageBubble(message: msg)
                                        .id(msg.id)
                                }
                                
                                // Typing Indicator
                                if manager.isTyping {
                                    HStack {
                                        TypingIndicator()
                                            .padding(14)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(18)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 10)
                                    .id("TypingIndicator")
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .onChange(of: manager.messages.count) { _ in
                            if let last = manager.messages.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                        .onChange(of: manager.isTyping) { isTyping in
                            if isTyping {
                                withAnimation { proxy.scrollTo("TypingIndicator", anchor: .bottom) }
                            }
                        }
                    }
                    
                    // Input Alanı
                    inputArea
                }
            }
            .navigationTitle("AI Koç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { manager.clearHistory() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            TextField("Bir şey sor...", text: $inputText)
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .foregroundColor(.white)
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit { sendMessage() }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .cyan)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.black)
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        manager.sendMessage(text)
        inputText = ""
        isInputFocused = false
    }
}

// MARK: - Mesaj Balonu

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            if !message.isUser {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.cyan)
                    .frame(width: 32, height: 32)
                    .background(Color.cyan.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Text(message.text)
                .font(.body)
                .foregroundColor(.white)
                .padding(14)
                .background(message.isUser ? Color.cyan : Color.white.opacity(0.1))
                .cornerRadius(18)
                // Köşeleri sivriltme efekti
                .clipShape(
                    RoundedCorner(radius: 18, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                )
            
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

// MARK: - Yardımcı: Yuvarlak Köşe

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var opacities: [Double] = [0.3, 0.3, 0.3]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .opacity(opacities[i])
                    .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(0.2 * Double(i)), value: opacities[i])
            }
        }
        .onAppear {
            for i in 0..<3 { opacities[i] = 1.0 }
        }
    }
}
