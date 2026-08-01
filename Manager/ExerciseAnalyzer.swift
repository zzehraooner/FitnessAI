import Foundation
import CoreGraphics
import Vision

enum ExerciseState {
    case up
    case down
    case unknown
}

class ExerciseAnalyzer {
    // 3 nokta arasındaki açıyı hesaplar
    static func angle(between firstPoint: CGPoint, middlePoint: CGPoint, lastPoint: CGPoint) -> CGFloat {
        let firstAngle = atan2(firstPoint.y - middlePoint.y, firstPoint.x - middlePoint.x)
        let secondAngle = atan2(lastPoint.y - middlePoint.y, lastPoint.x - middlePoint.x)
        
        var angleDiff = abs(firstAngle - secondAngle) * 180 / .pi
        if angleDiff > 180 {
            angleDiff = 360 - angleDiff
        }
        return angleDiff
    }
    
    // Squat analizi
    static func analyzeSquat(hip: CGPoint?, knee: CGPoint?, ankle: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let hip = hip, let knee = knee, let ankle = ankle else {
            return (0, "Vücut tam olarak görünmüyor", .unknown)
        }
        
        let kneeAngle = angle(between: hip, middlePoint: knee, lastPoint: ankle)
        
        if kneeAngle > 150 {
            return (0, "Squat için çömelmeye başlayın", .up)
        } else if kneeAngle <= 110 && kneeAngle >= 70 {
            return (100, "Mükemmel Form!", .down)
        } else if kneeAngle < 70 {
            return (80, "Çok fazla çömeliyorsunuz!", .down)
        } else {
            let percentage = 100 - ((kneeAngle - 110) / 40) * 100
            return (Double(percentage), "Daha fazla çömelin", .unknown)
        }
    }
    
    // Şınav (Push-up) analizi
    static func analyzePushup(shoulder: CGPoint?, elbow: CGPoint?, wrist: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let elbow = elbow, let wrist = wrist else {
            return (0, "Kolunuz tam olarak görünmüyor", .unknown)
        }
        
        let elbowAngle = angle(between: shoulder, middlePoint: elbow, lastPoint: wrist)
        
        // Şınavda yukarıdayken kollar gergindir (160-180 derece)
        // Aşağıdayken dirsekler bükülür (70-100 derece)
        if elbowAngle > 150 {
            return (0, "Aşağı inmeye başlayın", .up)
        } else if elbowAngle <= 100 && elbowAngle >= 70 {
            return (100, "Harika! Şimdi yukarı kalkın.", .down)
        } else if elbowAngle < 70 {
            return (80, "Çok fazla indiniz, omuzlara dikkat!", .down)
        } else {
            let percentage = 100 - ((elbowAngle - 100) / 50) * 100
            return (Double(percentage), "Daha fazla inin", .unknown)
        }
    }
    
    // Lunge analizi
    static func analyzeLunge(hip: CGPoint?, knee: CGPoint?, ankle: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let hip = hip, let knee = knee, let ankle = ankle else {
            return (0, "Vücut tam olarak görünmüyor", .unknown)
        }
        
        let kneeAngle = angle(between: hip, middlePoint: knee, lastPoint: ankle)
        
        if kneeAngle > 150 {
            return (0, "Hamle (Lunge) için inmeye başlayın", .up)
        } else if kneeAngle <= 100 && kneeAngle >= 70 {
            return (100, "Mükemmel Hamle!", .down)
        } else if kneeAngle < 70 {
            return (80, "Diziniz çok kırıldı, dikkat!", .down)
        } else {
            let percentage = 100 - ((kneeAngle - 100) / 50) * 100
            return (Double(percentage), "Daha fazla inin", .unknown)
        }
    }
    
    // Jumping Jacks analizi (Kolların Vücutla Açısı)
    static func analyzeJumpingJacks(hip: CGPoint?, shoulder: CGPoint?, wrist: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let hip = hip, let shoulder = shoulder, let wrist = wrist else {
            return (0, "Kollar görünmüyor", .unknown)
        }
        
        // Kolların omuzdan ne kadar kalktığına bakıyoruz
        let armAngle = angle(between: hip, middlePoint: shoulder, lastPoint: wrist)
        
        // Kollar aşağıda (0-40 derece) -> state .up (başlangıç pozisyonu)
        // Kollar yukarıda (140-180 derece) -> state .down (zıplama zirvesi)
        if armAngle < 40 {
            return (0, "Kolları açarak zıplayın", .up)
        } else if armAngle > 130 {
            return (100, "Harika! Şimdi kapanın.", .down)
        } else {
            let percentage = (armAngle / 130) * 100
            return (Double(percentage), "Daha fazla açılın", .unknown)
        }
    }
    
    // Mekik (Sit-up) analizi
    static func analyzeSitup(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let hip = hip, let knee = knee else {
            return (0, "Gövde görünmüyor", .unknown)
        }
        
        let torsoAngle = angle(between: shoulder, middlePoint: hip, lastPoint: knee)
        
        // Yatış pozisyonu (130-180)
        // Kalkış pozisyonu (40-80)
        if torsoAngle > 130 {
            return (0, "Kalkmaya başlayın", .up)
        } else if torsoAngle <= 80 && torsoAngle >= 40 {
            return (100, "Tam mekik! Geri yatın.", .down)
        } else if torsoAngle < 40 {
            return (80, "Çok fazla kapandınız", .down)
        } else {
            let percentage = 100 - ((torsoAngle - 80) / 50) * 100
            return (Double(percentage), "Daha fazla kalkın", .unknown)
        }
    }
    
    // Bicep Curl analizi
    static func analyzeBicepCurl(shoulder: CGPoint?, elbow: CGPoint?, wrist: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let elbow = elbow, let wrist = wrist else {
            return (0, "Kol görünmüyor", .unknown)
        }
        
        let elbowAngle = angle(between: shoulder, middlePoint: elbow, lastPoint: wrist)
        
        // Kol düz (150-180)
        // Kol bükük (30-60)
        if elbowAngle > 150 {
            return (0, "Dumbell'ı kaldırın", .up)
        } else if elbowAngle <= 60 && elbowAngle >= 20 {
            return (100, "İyi sıkıştırma! Yavaşça indirin.", .down)
        } else {
            let percentage = 100 - ((elbowAngle - 60) / 90) * 100
            return (Double(percentage), "Daha fazla bükün", .unknown)
        }
    }
    
    // Omuz Presi (Shoulder Press) Analizi
    static func analyzeShoulderPress(shoulder: CGPoint?, elbow: CGPoint?, wrist: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let elbow = elbow, let wrist = wrist else {
            return (0, "Kol görünmüyor", .unknown)
        }
        
        let elbowAngle = angle(between: shoulder, middlePoint: elbow, lastPoint: wrist)
        
        // Yukarı tam itilmiş (150-180) -> state .up
        // Aşağı indirilmiş (60-90) -> state .down
        if elbowAngle > 150 {
            return (100, "Harika! Kontrollü indirin.", .up)
        } else if elbowAngle <= 90 {
            return (0, "Dumbell'ı yukarı itin", .down)
        } else {
            let percentage = ((elbowAngle - 90) / 60) * 100
            return (Double(percentage), "Daha fazla itin", .unknown)
        }
    }
    
    // Deadlift Analizi
    static func analyzeDeadlift(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let hip = hip, let knee = knee else {
            return (0, "Gövde görünmüyor", .unknown)
        }
        
        // Kalça menteşesi açısı (Belden eğilme)
        let hipAngle = angle(between: shoulder, middlePoint: hip, lastPoint: knee)
        
        // Tam dik duruş (160-180) -> state .up
        // Eğilme (60-100) -> state .down
        if hipAngle > 160 {
            return (100, "Süper! Yavaşça eğilin.", .up)
        } else if hipAngle <= 100 {
            return (0, "Belinizle değil kalçayla kalkın", .down)
        } else {
            let percentage = ((hipAngle - 100) / 60) * 100
            return (Double(percentage), "Doğrulmaya başlayın", .unknown)
        }
    }
    
    // Yüksek Diz Çekme (High Knees) Analizi
    static func analyzeHighKnees(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let hip = hip, let knee = knee else {
            return (0, "Bacak görünmüyor", .unknown)
        }
        
        // Bacak göğse çekildiğindeki kalça açısı
        let hipAngle = angle(between: shoulder, middlePoint: hip, lastPoint: knee)
        
        // Normal ayakta duruş (160-180) -> state .down (veya başlangıç)
        // Diz yukarıda (70-110) -> state .up
        if hipAngle > 150 {
            return (0, "Dizinizi göğsünüze çekin", .down)
        } else if hipAngle <= 110 {
            return (100, "İyi yükseklik!", .up)
        } else {
            let percentage = 100 - ((hipAngle - 110) / 40) * 100
            return (Double(percentage), "Daha yükseğe çekin", .unknown)
        }
    }
    
    // Yana Kol Açma (Lateral Raises) Analizi
    static func analyzeLateralRaises(hip: CGPoint?, shoulder: CGPoint?, wrist: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let hip = hip, let shoulder = shoulder, let wrist = wrist else {
            return (0, "Kol görünmüyor", .unknown)
        }
        
        // Kolun gövdeyle yaptığı açı
        let armAngle = angle(between: hip, middlePoint: shoulder, lastPoint: wrist)
        
        // Kollar aşağıda (0-30) -> state .down
        // Kollar yana açık (70-100) -> state .up
        if armAngle < 35 {
            return (0, "Kolları yana açın", .down)
        } else if armAngle >= 75 && armAngle <= 110 {
            return (100, "Kollar hizada, indirin.", .up)
        } else if armAngle > 110 {
            return (80, "Çok fazla yukarı kaldırdınız!", .up)
        } else {
            let percentage = (armAngle / 75) * 100
            return (Double(percentage), "Daha yukarı açın", .unknown)
        }
    }
    
    // Kalça Köprüsü (Glute Bridge) Analizi
    static func analyzeGluteBridge(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let hip = hip, let knee = knee else {
            return (0, "Gövde görünmüyor", .unknown)
        }
        
        // Yerdeyken kalçanın bükülme açısı
        let hipAngle = angle(between: shoulder, middlePoint: hip, lastPoint: knee)
        
        // Kalça yerde (90-130) -> state .down
        // Kalça köprüde tam sıkılı (160-180) -> state .up
        if hipAngle < 130 {
            return (0, "Kalçayı yukarı sıkın", .down)
        } else if hipAngle >= 160 {
            return (100, "Köprü tamam! Kalçayı indirin.", .up)
        } else {
            let percentage = ((hipAngle - 130) / 30) * 100
            return (Double(percentage), "Kalçayı daha çok kaldırın", .unknown)
        }
    }
    
    // 1. Kalf Kaldırma (Calf Raises)
    static func analyzeCalfRaises(hip: CGPoint?, knee: CGPoint?, ankle: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let hip = hip, let knee = knee, let ankle = ankle else {
            return (0, "Bacak görünmüyor", .unknown)
        }
        let ankleAngle = angle(between: knee, middlePoint: ankle, lastPoint: CGPoint(x: ankle.x + 0.1, y: ankle.y)) // Yatay ile açı
        // Basitçe diz açısına da bakılabilir ama kalf için topuk kalkması izlenmeli.
        // Basitleştirilmiş: Kalça, diz ve bilek açısı esnemesi (parmak ucuna çıkışta bacak tam gergin olur)
        let legAngle = angle(between: hip, middlePoint: knee, lastPoint: ankle)
        if legAngle < 160 {
            return (0, "Bacaklarınızı düz tutun", .unknown)
        }
        // Topuk kalkmasını tespit etmek için ankle y koordinatı düşer (ters eksende yükselir)
        // Gerçek bir 3 boyutlu açı zor olduğu için basit bir açı farkı sayacı kullanıyoruz.
        return (100, "Parmak ucuna çıkın", .up) // Sembolik
    }
    
    // 2. Arka Kol Dips (Tricep Dips)
    static func analyzeTricepDips(shoulder: CGPoint?, elbow: CGPoint?, wrist: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let elbow = elbow, let wrist = wrist else {
            return (0, "Kol görünmüyor", .unknown)
        }
        let elbowAngle = angle(between: shoulder, middlePoint: elbow, lastPoint: wrist)
        if elbowAngle > 150 {
            return (0, "Dips için aşağı inin", .up)
        } else if elbowAngle <= 100 {
            return (100, "Süper! Kendinizi yukarı itin.", .down)
        } else {
            let p = 100 - ((elbowAngle - 100) / 50) * 100
            return (Double(p), "Daha fazla inin", .unknown)
        }
    }
    
    // 3. Bacak Kaldırma (Leg Raises)
    static func analyzeLegRaises(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let hip = hip, let knee = knee else {
            return (0, "Gövde görünmüyor", .unknown)
        }
        let hipAngle = angle(between: shoulder, middlePoint: hip, lastPoint: knee)
        if hipAngle > 160 {
            return (0, "Bacaklarınızı kaldırın", .down)
        } else if hipAngle <= 100 {
            return (100, "Süper! Yavaşça indirin.", .up)
        } else {
            let p = 100 - ((hipAngle - 100) / 60) * 100
            return (Double(p), "Daha yukarı kaldırın", .unknown)
        }
    }
    
    // 4. Öne Kol Kaldırma (Front Raises)
    static func analyzeFrontRaises(hip: CGPoint?, shoulder: CGPoint?, wrist: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let hip = hip, let shoulder = shoulder, let wrist = wrist else {
            return (0, "Kol görünmüyor", .unknown)
        }
        let armAngle = angle(between: hip, middlePoint: shoulder, lastPoint: wrist)
        if armAngle < 35 {
            return (0, "Kolları öne doğru kaldırın", .down)
        } else if armAngle >= 80 {
            return (100, "Hiza iyi, yavaşça indirin.", .up)
        } else {
            let p = (armAngle / 80) * 100
            return (Double(p), "Daha yukarı kaldırın", .unknown)
        }
    }
    
    // 5. Dağ Tırmanışı (Mountain Climbers)
    static func analyzeMountainClimbers(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let hip = hip, let knee = knee else {
            return (0, "Gövde görünmüyor", .unknown)
        }
        let hipAngle = angle(between: shoulder, middlePoint: hip, lastPoint: knee)
        if hipAngle > 150 {
            return (0, "Dizi göğse çekin", .down)
        } else if hipAngle <= 100 {
            return (100, "İyi çekiş!", .up)
        } else {
            let p = 100 - ((hipAngle - 100) / 50) * 100
            return (Double(p), "Daha fazla çekin", .unknown)
        }
    }
    
    // 6. Geriye Tekme (Donkey Kicks)
    static func analyzeDonkeyKicks(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let hip = hip, let knee = knee else {
            return (0, "Gövde görünmüyor", .unknown)
        }
        let hipAngle = angle(between: shoulder, middlePoint: hip, lastPoint: knee)
        if hipAngle < 100 {
            return (0, "Bacağınızı geriye atın", .down)
        } else if hipAngle >= 150 {
            return (100, "Harika! Geri çekin.", .up)
        } else {
            let p = ((hipAngle - 100) / 50) * 100
            return (Double(p), "Daha geriye atın", .unknown)
        }
    }
    
    // 7. Yarım Mekik (Crunch)
    static func analyzeCrunch(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let hip = hip, let knee = knee else {
            return (0, "Gövde görünmüyor", .unknown)
        }
        let torsoAngle = angle(between: shoulder, middlePoint: hip, lastPoint: knee)
        if torsoAngle > 140 {
            return (0, "Omuzları yerden kaldırın", .up)
        } else if torsoAngle <= 110 {
            return (100, "Yarım mekik! Geri yatın.", .down)
        } else {
            let p = 100 - ((torsoAngle - 110) / 30) * 100
            return (Double(p), "Biraz daha sıkıştırın", .unknown)
        }
    }
    
    // 8. Eğilerek Çekiş (Bent Over Row)
    static func analyzeBentOverRow(shoulder: CGPoint?, elbow: CGPoint?, wrist: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let shoulder = shoulder, let elbow = elbow, let wrist = wrist else {
            return (0, "Kol görünmüyor", .unknown)
        }
        let elbowAngle = angle(between: shoulder, middlePoint: elbow, lastPoint: wrist)
        if elbowAngle > 150 {
            return (0, "Ağırlığı karna doğru çekin", .down)
        } else if elbowAngle <= 90 {
            return (100, "İyi çekiş! İndirin.", .up)
        } else {
            let p = 100 - ((elbowAngle - 90) / 60) * 100
            return (Double(p), "Daha fazla çekin", .unknown)
        }
    }
    
    // 9. Sumo Squat
    static func analyzeSumoSquat(hip: CGPoint?, knee: CGPoint?, ankle: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        // Squat ile aynı açıyı kullanır, sadece duruş genişliği farklıdır
        return analyzeSquat(hip: hip, knee: knee, ankle: ankle)
    }
    
    // 10. Good Mornings
    static func analyzeGoodMornings(shoulder: CGPoint?, hip: CGPoint?, knee: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        // Deadlift ile aynı bel açısını kullanır, ağırlık sırttadır
        return analyzeDeadlift(shoulder: shoulder, hip: hip, knee: knee)
    }
    
    // YOGA: Ağaç Duruşu (Tree Pose)
    static func analyzeTreePose(hip: CGPoint?, knee: CGPoint?, ankle: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let hip = hip, let knee = knee, let ankle = ankle else {
            return (0, "Vücut görünmüyor", .unknown)
        }
        
        let legAngle = angle(between: hip, middlePoint: knee, lastPoint: ankle)
        
        // Bir bacağın kırık (ağaç pozu) olması durumu (60-120 derece)
        // Sabit (stable) pozisyon .up olarak değerlendirilir.
        if legAngle > 60 && legAngle < 130 {
            return (100, "Odaklanın ve dengede kalın!", .up)
        } else {
            return (0, "Ayağınızı dizinize yerleştirin", .down)
        }
    }
    
    // YOGA: Savaşçı (Warrior Pose)
    static func analyzeWarriorPose(hip: CGPoint?, shoulder: CGPoint?, wrist: CGPoint?) -> (percentage: Double, message: String, state: ExerciseState) {
        guard let hip = hip, let shoulder = shoulder, let wrist = wrist else {
            return (0, "Vücut görünmüyor", .unknown)
        }
        
        // Kolların yere paralel açılması (70-110 derece arası)
        let armAngle = angle(between: hip, middlePoint: shoulder, lastPoint: wrist)
        
        if armAngle > 70 && armAngle < 110 {
            return (100, "Güçlü durun, pozisyonu koruyun!", .up)
        } else {
            return (0, "Kollarınızı yana doğru açın", .down)
        }
    }
}
