import SwiftUI

struct LockScreenWidget: View {
    var intent: Intent
    var progress: Double
    
    var body: some View {
        HStack {
            CircularProgressView(progress: progress)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text("FOCUS")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Text(intent.text)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
        }
    }
}

// Helper for circular progress
struct CircularProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: 270.0))
        }
    }
}
