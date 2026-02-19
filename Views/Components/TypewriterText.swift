import SwiftUI

struct TypewriterText: View {
    let text: String
    let font: Font
    var color: Color = .primary
    
    @State private var displayedText: String = ""
    @State private var timer: Timer?
    
    var body: some View {
        Text(displayedText)
            .font(font)
            .foregroundColor(color)
            .onAppear {
                animateText()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
    
    private func animateText() {
        displayedText = ""
        var charIndex = 0
        let chars = Array(text)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            if charIndex < chars.count {
                displayedText.append(chars[charIndex])
                charIndex += 1
                
                // Light haptic tick for typing feel?
                if charIndex % 3 == 0 {
                    // HapticManager.shared.playImpact(style: .soft) // Optional
                }
            } else {
                t.invalidate()
            }
        }
    }
}
