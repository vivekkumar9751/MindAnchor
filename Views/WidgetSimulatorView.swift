import SwiftUI

struct WidgetSimulatorView: View {
    @State private var progress: Double = 0.3
    @State private var isFocusMode: Bool = true
    
    // Simulate Activity state
    let intentText = "Writing System Spec"
    let intentWhy = "Required for launch"
    let targetDate = Date().addingTimeInterval(1800)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                
                // Controls
                VStack {
                    Text("Widget Simulator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Slider(value: $progress, in: 0...1) {
                        Text("Progress")
                    }
                    Text("Progress: \(Int(progress * 100))%")
                        .font(.caption)
                    
                    Toggle("Focus Mode Active", isOn: $isFocusMode)
                }
                .padding()
                
                Divider()
                
                // Section 1: Lock Screen Widget (Rectangular)
                VStack(alignment: .leading) {
                    Text("Lock Screen (Rectangular)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        // Simulated Lock Screen Context
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "timer")
                                Text("FOCUS")
                                    .fontWeight(.bold)
                            }
                            .font(.caption2)
                            
                            Text(intentText)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            ProgressView(value: progress)
                                .tint(.white)
                        }
                        .padding()
                        .frame(width: 150, height: 70)
                        .background(Color.black.opacity(0.8)) // Dark mode simulation
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                }
                
                // Section 2: Dynamic Island (Expanded)
                VStack(alignment: .leading) {
                    Text("Dynamic Island (Expanded)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .top) {
                        // Leading
                        VStack(alignment: .leading) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.blue)
                            Text("\(Int((1.0 - progress) * 30))m")
                                .font(.title)
                                .fontWeight(.bold)
                                .monospacedDigit()
                        }
                        
                        Spacer()
                        
                        // Center/Trailing content
                        VStack(alignment: .trailing) {
                            Text(intentText)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(intentWhy)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: progress)
                                .tint(.green)
                                .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground)) // Island background logic is complex, simulating dark
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 2)
                    )
                }
                .padding()
                
                // Section 3: Home Screen Widget (Small)
                VStack(alignment: .leading) {
                    Text("Home Screen (Small)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .stroke(lineWidth: 4)
                                .foregroundColor(.blue.opacity(0.3))
                                .overlay(
                                    Circle()
                                        .trim(from: 0, to: progress)
                                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                        .foregroundColor(.blue)
                                        .rotationEffect(.degrees(-90))
                                )
                                .frame(width: 40, height: 40)
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(intentText)
                            .font(.headline)
                            .lineLimit(2)
                        
                        Text(intentWhy)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .padding()
                    .frame(width: 150, height: 150) // Standard Small Widget Size
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                }
                
                Spacer()
            }
        }
        .navigationTitle("System Integration")
    }
}
