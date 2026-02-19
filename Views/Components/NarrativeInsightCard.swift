import SwiftUI

struct NarrativeInsightCard: View {
    let insight: String
    
    // Determine icon and color based on content (simple keyword matching)
    private var style: (icon: String, color: Color) {
        if insight.contains("Morning") || insight.contains("☀️") {
            return ("sunrise.fill", .orange)
        } else if insight.contains("Evening") || insight.contains("🌙") {
            return ("moon.stars.fill", .indigo)
        } else if insight.contains("streak") || insight.contains("🔥") {
            return ("flame.fill", .red)
        } else if insight.contains("Focus") || insight.contains("active") {
            return ("brain.head.profile", .blue)
        } else if insight.contains("Consistency") {
            return ("chart.bar.doc.horizontal.fill", .green)
        } else {
            return ("sparkles", .purple)
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: style.icon)
                .font(.title2)
                .foregroundColor(style.color)
                .frame(width: 40, height: 40)
                .background(style.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Insight")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(style.color)
                    .textCase(.uppercase)
                
                Text(insight)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style.color.opacity(0.2), lineWidth: 1)
        )
    }
}
