import SwiftUI

struct MindAnchorWidgetView: View {
    var intent: Intent
    var progress: Double
    var isFocusMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CircularProgressView(progress: progress)
                    .frame(width: 30, height: 30)
                    .foregroundColor(isFocusMode ? .blue : .gray)
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .foregroundColor(isFocusMode ? .blue : .gray)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(intent.text)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(intent.why)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}
