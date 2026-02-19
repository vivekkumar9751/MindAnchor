import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Logo / Title
                    VStack(spacing: 8) {
                        Image(systemName: "anchor.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("MindAnchor")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("v1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Philosophy Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Philosophy")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("In a frantic world, reclaiming your attention is a radical act.")
                            .font(.body)
                        
                        Text("MindAnchor is designed to help you capture fleeting thoughts, anchor yourself in the present moment, and reflect on your emotional journey.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground)) // Keeping it simple for now, could be material later
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Features Section
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "plus.circle.fill", title: "Capture", description: "Quickly jot down what's distracting you or what requires your focus.")
                        FeatureRow(icon: "timer", title: "Anchor", description: "Set a dedicated time to focus. Use deep work or flow techniques.")
                        FeatureRow(icon: "chart.bar.fill", title: "Reflect", description: "Understand your patterns and emotions over time.")
                    }
                    .padding()
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("Designed with 💙 for Focus")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
