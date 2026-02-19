import SwiftUI

struct FluidGradientView: View {
    @State private var blobs: [Blob] = []
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                
                // Draw blobs
                for blob in blobs {
                    let x = blob.x + sin(time * blob.speedX + blob.phaseX) * 0.2
                    let y = blob.y + cos(time * blob.speedY + blob.phaseY) * 0.2
                    
                    let rect = CGRect(
                        x: x * size.width,
                        y: y * size.height,
                        width: size.width * blob.scale,
                        height: size.width * blob.scale
                    )
                    
                    context.fill(Path(ellipseIn: rect), with: .color(blob.color.opacity(0.6)))
                }
            }
            .blur(radius: 60) // Heavy blur for "fluid" effect
        }
        .onAppear {
            createBlobs()
        }
        .ignoresSafeArea()
        .background(Color(UIColor.systemBackground)) // Base layer
    }
    
    private func createBlobs() {
        blobs = [
            Blob(color: .blue, x: 0.2, y: 0.2, scale: 0.8),
            Blob(color: .purple, x: 0.8, y: 0.3, scale: 0.7),
            Blob(color: .cyan, x: 0.5, y: 0.8, scale: 0.9),
            Blob(color: .indigo, x: 0.1, y: 0.9, scale: 0.6)
        ]
    }
}

struct Blob {
    var color: Color
    var x: Double // 0-1
    var y: Double // 0-1
    var scale: Double
    var speedX: Double = Double.random(in: 0.3...0.8)
    var speedY: Double = Double.random(in: 0.3...0.8)
    var phaseX: Double = Double.random(in: 0...10)
    var phaseY: Double = Double.random(in: 0...10)
}
