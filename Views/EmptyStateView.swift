import SwiftUI

struct EmptyStateView: View {
    var onCapture: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "wind")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Nothing is anchored right now.")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: onCapture) {
                Text("Capture a Thought")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}
