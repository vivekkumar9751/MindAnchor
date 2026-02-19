import ActivityKit
import WidgetKit
import SwiftUI

struct MindAnchorLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            // Lock Screen UI
            HStack {
                // Leading: Icon + Timer
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                        Text(timerInterval: Date()...context.attributes.targetDate, countsDown: true)
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Text(context.attributes.intentText)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Trailing: Progress + Visuals
                VStack(alignment: .trailing) {
                    CircularActivityProgress(progress: context.state.progress)
                        .frame(width: 40, height: 40)
                    
                    if context.state.isFocusMode {
                        Text("FOCUS ON")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.intentText, systemImage: "brain.head.profile")
                        .font(.caption2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Label {
                        Text(timerInterval: Date()...context.attributes.targetDate, countsDown: true)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 50)
                            .monospacedDigit()
                    } icon: {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                    }
                    .font(.caption2)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Spacer()
                        Text(context.attributes.intentWhy)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            } compactLeading: {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
            } compactTrailing: {
                Text(timerInterval: Date()...context.attributes.targetDate, countsDown: true)
                    .monospacedDigit()
                    .font(.caption2)
                    .foregroundColor(.blue)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct CircularActivityProgress: View {
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
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
        }
    }
}
