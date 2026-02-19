import SwiftUI
import Charts

struct IntentArchiveView: View {
    @EnvironmentObject var intentManager: IntentManager
    
    // Group intents by day for the chart
    var dailyFocusData: [DailyFocus] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: intentManager.history) { intent in
            calendar.startOfDay(for: intent.createdAt)
        }
        
        return grouped.map { (date, intents) in
            let totalMinutes = intents.reduce(0) { result, intent in
                    // If we had actual duration recorded, we'd use it. 
                    // For now, we use estimatedDuration or a default if missing, 
                    // or calculate from start/end if we had an end time.
                    // Let's use estimatedDuration / 60 for now as a proxy for "planned focus".
                    result + (intent.estimatedDuration ?? 0) / 60
            }
            return DailyFocus(date: date, minutes: totalMinutes)
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // Insights Section
                let insights = InsightEngine.shared.calculateInsights(history: intentManager.history)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    InsightCard(
                        title: "Focus Time",
                        value: "\(insights.totalFocusMinutes)m",
                        icon: "hourglass",
                        color: .orange
                    )
                    
                    InsightCard(
                        title: "Current Streak",
                        value: "\(insights.currentStreak) Days",
                        icon: "flame.fill",
                        color: .red
                    )
                    
                    InsightCard(
                        title: "Sessions",
                        value: "\(insights.completeSessions)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    InsightCard(
                        title: "Top Emotion",
                        value: insights.topEmotion ?? "N/A",
                        icon: "heart.fill",
                        color: .pink
                    )
                }
                .padding(.horizontal)
                
                // Intelligent Insights Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Focus Insights")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if insights.narratives.isEmpty {
                        Text("Complete more sessions to unlock personalized insights.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(insights.narratives, id: \.self) { narrative in
                                    NarrativeInsightCard(insight: narrative)
                                        .frame(width: 280) // Fixed width for horizontal scrolling cards
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
                
                // List Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Anchors")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(intentManager.history.reversed()) { intent in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(intent.text)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Text(intent.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let emotion = intent.completionEmotion {
                                Text(emotion)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Journey")
    }
}

struct DailyFocus: Identifiable {
    var id: Date { date }
    var date: Date
    var minutes: Double
}
