import Foundation
import AVFoundation

class SpeechManager {
    static let shared = SpeechManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var lastSpokenMessage: String = ""
    private var lastSpokenTime: Date = Date()
    
    private init() {
        // Arka planda müzik çalarken de konuşabilmesi için ses ayarlarını yapıyoruz
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Ses ayarı yapılamadı: \(error)")
        }
    }
    
    func speak(_ message: String, force: Bool = false) {
        // Aynı mesajı üst üste sürekli söylemesini engellemek için filtre (force edilmediyse)
        if !force {
            if message == lastSpokenMessage && Date().timeIntervalSince(lastSpokenTime) < 3.0 {
                return
            }
        }
        
        // Eğer zaten bir şey söylüyorsa veya söyleyecekse durdur (Sesi anında ver)
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "tr-TR") // Türkçe ses
        utterance.rate = 0.5 // Konuşma hızı (normal)
        utterance.pitchMultiplier = 1.0 // Ses tonu
        utterance.volume = 1.0 // Ses seviyesi
        
        synthesizer.speak(utterance)
        
        lastSpokenMessage = message
        lastSpokenTime = Date()
    }
}
