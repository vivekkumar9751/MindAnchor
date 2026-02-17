import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "info.circle")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("MindAnchor")
                .font(.title)
                .fontWeight(.bold)
            
            Text("MindAnchor preserves thinking context instead of managing time.\n\nBecause people don’t lose focus — they lose context.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button("Close") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}
