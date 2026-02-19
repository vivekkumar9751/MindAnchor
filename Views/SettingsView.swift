import SwiftUI

struct SettingsView: View {
    @AppStorage("focusPhilosophy") private var philosophyRaw: String = AnchorPhilosophy.undecided.rawValue
    @AppStorage("narrativeMode") private var narrativeMode: Bool = true
    @AppStorage("hapticFeedback") private var hapticFeedback: Bool = true
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = true
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var selectedPhilosophy: AnchorPhilosophy {
        AnchorPhilosophy(rawValue: philosophyRaw) ?? .undecided
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                FluidGradientView()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Anchor Philosophy")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("What kind of focus feels right for you?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Philosophy Picker
                        VStack(spacing: 12) {
                            ForEach(AnchorPhilosophy.allCases) { philosophy in
                                PhilosophyOptionCard(
                                    philosophy: philosophy,
                                    isSelected: selectedPhilosophy == philosophy
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        philosophyRaw = philosophy.rawValue
                                        HapticManager.shared.playImpact(style: .light)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Preferences
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Preferences")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            SettingsToggleRow(
                                icon: "text.bubble.fill",
                                iconColor: .blue,
                                title: "Narrative Mode",
                                subtitle: "Personal, story-driven insights after each session",
                                isOn: $narrativeMode
                            )
                            
                            SettingsToggleRow(
                                icon: "iphone.radiowaves.left.and.right",
                                iconColor: .orange,
                                title: "Haptic Feedback",
                                subtitle: "Gentle vibrations to ground you in the moment",
                                isOn: $hapticFeedback
                            )
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Danger Zone
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Other")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            Button(action: {
                                hasOnboarded = false
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(.red)
                                    Text("Replay Onboarding")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(14)
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Philosophy Option Card

struct PhilosophyOptionCard: View {
    let philosophy: AnchorPhilosophy
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(philosophy.accentColor.opacity(isSelected ? 0.3 : 0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: philosophy.icon)
                        .font(.title3)
                        .foregroundColor(philosophy.accentColor)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(philosophy.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(philosophy.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(philosophy.accentColor)
                        .font(.title3)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? philosophy.accentColor.opacity(0.08) : Color(UIColor.secondarySystemBackground).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? philosophy.accentColor : Color.clear, lineWidth: 2)
                    )
            )
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .accessibilityLabel("\(philosophy.rawValue). \(philosophy.subtitle)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
        .padding(.horizontal)
    }
}
