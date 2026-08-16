import SwiftUI

struct BadgesView: View {
    @StateObject private var gm = GamificationManager.shared

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: — Level & XP Kartı
                        levelCard

                        // MARK: — Günlük Görevler
                        dailyGoalsSection

                        // MARK: — Rozet Grid
                        badgesSection

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Başarılar")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Yeni rozet popup
        .overlay(alignment: .top) {
            if let badge = gm.pendingBadge {
                BadgeUnlockBanner(badge: badge) {
                    gm.pendingBadge = nil
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: gm.pendingBadge != nil)
            }
        }
    }

    // MARK: - Level Kartı

    private var levelCard: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center) {
                // Sol: Level ikonu
                ZStack {
                    Circle()
                        .fill(levelGradient)
                        .frame(width: 70, height: 70)
                    Text("\(gm.level)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(gm.levelTitle)
                        .font(.title2).fontWeight(.heavy).foregroundColor(.white)
                    Text("\(gm.totalXP) XP toplam")
                        .font(.caption).foregroundColor(.gray)
                    Text("\(gm.xpForNextLevel - gm.totalXP) XP sonraki levele")
                        .font(.caption2).foregroundColor(.gray.opacity(0.7))
                }
                .padding(.leading, 8)

                Spacer()

                // Sağ: Kazanılan rozet sayısı
                VStack(spacing: 4) {
                    Text("\(gm.unlockedBadges.count)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                    Text("Rozet")
                        .font(.caption2).foregroundColor(.gray)
                }
            }

            // XP Progressbar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(levelGradient)
                            .frame(width: geo.size.width * CGFloat(gm.levelProgress), height: 12)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: gm.levelProgress)
                    }
                }
                .frame(height: 12)

                HStack {
                    Text("Lv. \(gm.level)")
                        .font(.caption2).foregroundColor(.gray)
                    Spacer()
                    Text("Lv. \(gm.level + 1)")
                        .font(.caption2).foregroundColor(.gray)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.07))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(levelGradient, lineWidth: 1))
        .padding(.horizontal)
    }

    private var levelGradient: LinearGradient {
        LinearGradient(
            colors: gm.level >= 10 ? [.yellow, .orange] :
                    gm.level >= 5  ? [.purple, .pink] :
                    [.cyan, .blue],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    // MARK: - Günlük Görevler

    private var dailyGoalsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Günlük Görevler", icon: "target", color: .orange)

            ForEach($gm.dailyGoals) { $goal in
                DailyGoalRow(goal: $goal)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Rozet Grid

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Rozetler", icon: "rosette", color: .yellow)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(gm.allBadges) { badge in
                    let isUnlocked = gm.unlockedBadges.contains(badge.id)
                    BadgeCard(badge: badge, isUnlocked: isUnlocked)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color)
            Text(title).font(.headline).fontWeight(.bold).foregroundColor(.white)
        }
    }
}

// MARK: - Günlük Görev Satırı

struct DailyGoalRow: View {
    @Binding var goal: DailyGoal

    var body: some View {
        HStack(spacing: 14) {
            // İkon
            ZStack {
                Circle()
                    .fill(goal.isCompleted ? Color.green.opacity(0.2) : Color.white.opacity(0.08))
                    .frame(width: 44, height: 44)
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : goal.icon)
                    .font(.title3)
                    .foregroundColor(goal.isCompleted ? .green : .orange)
            }

            // Metin
            VStack(alignment: .leading, spacing: 3) {
                Text(goal.title)
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                Text(goal.description)
                    .font(.caption2).foregroundColor(.gray)

                // Progressbar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(height: 5)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(goal.isCompleted ? Color.green : Color.orange)
                            .frame(width: geo.size.width * CGFloat(goal.progress), height: 5)
                            .animation(.spring(), value: goal.progress)
                    }
                }
                .frame(height: 5)
            }

            Spacer()

            // XP Ödülü
            VStack(spacing: 2) {
                Text("+\(goal.xpReward)")
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(goal.isCompleted ? .gray : .yellow)
                Text("XP")
                    .font(.caption2).foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(goal.isCompleted ? Color.green.opacity(0.07) : Color.white.opacity(0.06))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(
            goal.isCompleted ? Color.green.opacity(0.4) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Rozet Kartı

struct BadgeCard: View {
    let badge: Badge
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? badge.rarity.color.opacity(0.2) : Color.gray.opacity(0.08))
                    .frame(width: 70, height: 70)

                if isUnlocked {
                    Circle()
                        .strokeBorder(badge.rarity.color, lineWidth: 2)
                        .frame(width: 70, height: 70)
                }

                Image(systemName: badge.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? badge.rarity.color : .gray.opacity(0.3))
            }
            .shadow(color: isUnlocked ? badge.rarity.color.opacity(0.5) : .clear, radius: 8)

            Text(badge.name)
                .font(.caption2).fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(isUnlocked ? .white : .gray)
                .lineLimit(2)

            if isUnlocked {
                Text(badge.rarity.label)
                    .font(.system(size: 9))
                    .foregroundColor(badge.rarity.color)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(badge.rarity.color.opacity(0.2))
                    .cornerRadius(4)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption2).foregroundColor(.gray.opacity(0.4))
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(isUnlocked ? 0.07 : 0.03))
        .cornerRadius(16)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Yeni Rozet Banner

struct BadgeUnlockBanner: View {
    let badge: Badge
    let onDismiss: () -> Void
    @State private var show = true

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: badge.iconName)
                .font(.title2)
                .foregroundColor(badge.rarity.color)

            VStack(alignment: .leading, spacing: 2) {
                Text("Yeni Rozet Kazandın! 🎉")
                    .font(.caption2).foregroundColor(.gray)
                Text(badge.name)
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption).foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(badge.rarity.color, lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 60)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                onDismiss()
            }
        }
    }
}
