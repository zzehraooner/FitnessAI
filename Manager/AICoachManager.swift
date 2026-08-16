import Foundation
import Combine

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), text: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

class AICoachManager: ObservableObject {
    static let shared = AICoachManager()
    
    @Published var messages: [ChatMessage] = []
    @Published var isTyping: Bool = false
    
    // Güvenlik açısından API key'i normalde backend'den almalısınız veya Config dosyasında tutmalısınız.
    private let geminiAPIKey = "YOUR_GEMINI_API_KEY"
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    private let historyKey = "aicoach_chat_history"
    
    private init() {
        loadHistory()
        if messages.isEmpty {
            sendWelcomeMessage()
        }
    }
    
    // MARK: - Welcome & Context
    
    private func sendWelcomeMessage() {
        let msg = ChatMessage(text: "Merhaba! Ben senin yapay zeka antrenörünüm. Bugün son antrenman verilerini analiz edebilir veya aklına takılan herhangi bir soruyu cevaplayabilirim. Nasıl yardımcı olabilirim?", isUser: false)
        messages.append(msg)
        saveHistory()
    }
    
    func analyzeLatestSession() {
        guard let latest = SessionStore.shared.sessions.first else {
            messages.append(ChatMessage(text: "Henüz bir antrenman seansın görünmüyor. Bir egzersiz tamamladıktan sonra sana formun hakkında detaylı analiz verebilirim!", isUser: false))
            return
        }
        
        let prompt = "Son antrenmanım: \(latest.exerciseName), Tekrar: \(latest.totalReps), Süre: \(latest.durationSeconds / 60) dakika, Ortalama Form Yüzdem: %\(Int(latest.averageFormPercentage)). Bu veriler doğrultusunda bana antrenör gibi motive edici ve teknik olarak formumu nasıl geliştireceğime dair kısa bir tavsiye ver."
        
        sendMessage(prompt, isUser: true, hidden: true)
    }
    
    // MARK: - Messaging
    
    func sendMessage(_ text: String, isUser: Bool = true, hidden: Bool = false) {
        if !hidden {
            messages.append(ChatMessage(text: text, isUser: isUser))
            saveHistory()
        }
        
        guard isUser else { return }
        
        isTyping = true
        
        // Mock Gemini API call for architecture setup
        Task {
            let reply = await fetchGeminiResponse(for: text)
            
            DispatchQueue.main.async {
                self.isTyping = false
                self.messages.append(ChatMessage(text: reply, isUser: false))
                self.saveHistory()
            }
        }
    }
    
    // MARK: - Network Request
    
    private func fetchGeminiResponse(for prompt: String) async -> String {
        // Eğer API key girilmemişse mock data dön
        guard geminiAPIKey != "YOUR_GEMINI_API_KEY" else {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            return "Şu anda Gemini API anahtarı ayarlanmamış durumda. (Geliştirici ortamındayız). Ancak formun %85 üzerinde görünüyorsa harika iş çıkarıyorsun! Daha iyi sonuçlar için nefes kontrolüne odaklan."
        }
        
        guard let url = URL(string: "\(endpoint)?key=\(geminiAPIKey)") else { return "Bağlantı hatası." }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": "Sen uzman bir spor ve fitness koçusun. Kullanıcının şu sorusuna motive edici ve teknik olarak doğru cevap ver: \(prompt)"]
                    ]
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Basit JSON parse
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let first = candidates.first,
               let content = first["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                return text
            }
            return "Üzgünüm, API'den yanıt alamadım."
        } catch {
            return "Bağlantı sorunu oluştu: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Persistence
    
    func clearHistory() {
        messages = []
        sendWelcomeMessage()
        saveHistory()
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            messages = decoded
        }
    }
}
