import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        Text("Analizler")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.horizontal)
                        
                        // Günlük Tekrar Çubuk Grafiği
                        VStack(alignment: .leading) {
                            Text("Günlük Toplam Tekrar")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Chart {
                                ForEach(viewModel.dailyReps, id: \.date) { data in
                                    BarMark(
                                        x: .value("Gün", data.date, unit: .day),
                                        y: .value("Tekrar", data.count)
                                    )
                                    .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                                    .cornerRadius(5)
                                }
                            }
                            .frame(height: 220)
                            .chartYAxis {
                                AxisMarks(position: .leading) { _ in
                                    AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                                    AxisValueLabel().foregroundStyle(.gray)
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { _ in
                                    AxisValueLabel(format: .dateTime.weekday(), centered: true)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Egzersiz Dağılımı (Pasta Grafik)
                        VStack(alignment: .leading) {
                            Text("Egzersiz Dağılımı")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Chart {
                                ForEach(viewModel.exerciseDistribution, id: \.name) { data in
                                    SectorMark(
                                        angle: .value("Dağılım", data.count),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 1.5
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(by: .value("Egzersiz", data.name))
                                }
                            }
                            .frame(height: 250)
                            .chartLegend(position: .bottom, spacing: 20)
                            .chartForegroundStyleScale([
                                "Squat": Color.blue,
                                "Şınav": Color.orange,
                                "Tree Pose": Color.green
                            ])
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Form Gelişim Grafiği (Çizgi Grafik)
                        VStack(alignment: .leading) {
                            Text("Form Doğruluğu İlerlemesi")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Chart {
                                ForEach(viewModel.workoutSessions) { session in
                                    LineMark(
                                        x: .value("Tarih", session.date, unit: .day),
                                        y: .value("Form %", session.averageFormPercentage)
                                    )
                                    .foregroundStyle(.cyan)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    .symbol(Circle().strokeBorder(Color.white, lineWidth: 2))
                                    .symbolSize(100)
                                    
                                    AreaMark(
                                        x: .value("Tarih", session.date, unit: .day),
                                        yStart: .value("Min", 50),
                                        yEnd: .value("Form %", session.averageFormPercentage)
                                    )
                                    .foregroundStyle(LinearGradient(colors: [.cyan.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                                }
                            }
                            .frame(height: 220)
                            .chartYScale(domain: 50...100)
                            .chartYAxis {
                                AxisMarks(position: .leading) { _ in
                                    AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                                    AxisValueLabel().foregroundStyle(.gray)
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { _ in
                                    AxisValueLabel(format: .dateTime.weekday(), centered: true)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}
