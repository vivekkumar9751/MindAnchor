import SwiftUI

struct ReturnView: View {
    @EnvironmentObject var intentManager: IntentManager
    let intent: Intent
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let duration = sessionDuration {
                    Text("You focused for \(duration) before pausing.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 16) {
                Text(intent.text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(intent.why)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 5)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    intentManager.resumeIntent()
                }
            }) {
                Text("Resume Focus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            Button(action: {
                withAnimation {
                    intentManager.clearIntent()
                }
            }) {
                Text("Start Fresh")
                    .foregroundColor(.red)
            }
            .padding(.top, 10)
        }
        .padding()
    }
    
    var sessionDuration: String? {
        guard let pausedAt = intent.pausedAt else { return nil }
        let duration = pausedAt.timeIntervalSince(intent.createdAt)
        let minutes = Int(duration) / 60
        if minutes < 1 {
            return "less than a minute"
        } else {
            return "\(minutes) minutes"
        }
    }
}
