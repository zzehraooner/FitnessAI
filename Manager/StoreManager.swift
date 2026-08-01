import Foundation
import StoreKit
import Combine

class StoreManager: ObservableObject {
    @Published var isPremiumUser: Bool = false
    
    // Uygulama içi satın alımları dinleyen sistem (StoreKit 2)
    // Gerçekte burada ProductID ile Apple serverlarına bağlanılır.
    
    init() {
        checkSubscriptionStatus()
    }
    
    func checkSubscriptionStatus() {
        // Geçici olarak kullanıcıyı free kabul edelim.
        // Gerçek kodda: `Transaction.currentEntitlements` kontrol edilir.
        self.isPremiumUser = false
    }
    
    func purchasePremium() {
        // Satın alma simülasyonu
        // Gerçek kodda: `try await Product.purchase()` çağrılır.
        print("Premium satın alma başlatıldı (Sandbox simülasyonu)...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isPremiumUser = true
            print("Satın alma başarılı! Artık Premium üyesiniz.")
        }
    }
    
    func restorePurchases() {
        print("Geçmiş satın alımlar geri yükleniyor...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isPremiumUser = true
        }
    }
}
