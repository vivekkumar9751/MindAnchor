# 🧠 MindAnchor

> *One anchor. One intention. One session at a time.*

MindAnchor is a mindful focus companion built with SwiftUI for iOS. It helps you do one meaningful thing at a time — by anchoring your intention before you begin, holding your attention during the session, and reflecting on your growth when you finish.

Built as a submission for the **Swift Student Challenge (SSC)**.

---

## ✨ Features

### 🎯 Core Focus Flow
- **Intent Capture** — Name what you're doing and *why* it matters before you start
- **Single-task constraint** — Only one active anchor allowed at a time, by design
- **Anchor Screen** — Live countdown timer with ambient visuals and soundscape
- **Mindful Interruption Handler** — Log distractions non-judgmentally; distinguish *urgent* from *avoidance*
- **Hold-to-Complete** — Intentional gesture to close a session — no accidental completions
- **Overtime Haptic Alerts** — Repeating triple-vibration pulse when the timer expires and session isn't marked done; ring turns red, overtime counter starts (`+MM:SS`)

### 💬 Reflection & Growth
- **Emotional Check-In** — Tag your feeling at session end (Satisfied, Proud, Drained…)
- **Philosophy-aware Microcopy** — Completion message adapts to your philosophy (e.g. *"You stayed committed."* / *"You honored your attention."*)
- **Narrative Insights** — On-device `InsightEngine` generates personal, story-driven observations from your history (best focus time, emotional patterns, streaks)
- **Journey Timeline** — Scrollable archive of every completed anchor session

### 🌱 Anchor Philosophy
Choose (or change anytime) how your focus should feel:

| Philosophy | Visualization | Default Duration |
|---|---|---|
| ⚡ Deep Work | Stable expanding rings | 90 min |
| 🍃 Calm & Clarity | Soft breathing waves | 30 min |
| 🎨 Creative Flow | Floating particles | 45 min |
| 🛡 Discipline | Steady growing line | 60 min |
| ❓ Decide later | — | 30 min |

### ⚙️ Settings
- Change philosophy anytime via **Settings → Anchor Philosophy**
- Toggle **Narrative Mode** (personal story insights vs minimal)
- Toggle **Haptic Feedback**
- Replay onboarding

### 📱 Apple Platform Integration
- **Live Activity** — Focus timer visible on Lock Screen and in the Dynamic Island (via ActivityKit)
- **Home Screen Widget** — Current anchor and progress ring on your Home Screen (via WidgetKit)
- **Siri / App Shortcuts** — *"Start Focus in MindAnchor"* for hands-free session start
- **UserDefaults + Core Data** — All intent history persisted locally, zero cloud dependency

### ♿ Accessibility
- Full **VoiceOver** support with descriptive labels on every element
- **Dynamic Type** — All text scales with iOS system font size
- **Reduce Motion** — All animations replaced with static alternatives when enabled
- **Haptic Feedback** toggle in Settings for sensory-sensitive users

---

## 🏗 Architecture

```
MindAnchor.swiftpm/
├── MyApp.swift                  # App entry point + DI setup
├── ContentView.swift            # Root navigation + state routing
├── Data/
│   ├── Intent.swift             # Core model
│   ├── IntentManager.swift      # Business logic + Live Activity management (@MainActor)
│   ├── PersistenceController.swift  # Core Data stack
│   ├── InsightEngine.swift      # On-device narrative insight generator
│   ├── AnchorPhilosophy.swift   # Philosophy enum (microcopy, defaults, viz style)
│   ├── FocusActivityAttributes.swift  # ActivityKit model
│   ├── FocusAppIntents.swift    # AppIntents / Siri integration
│   └── WidgetDataManager.swift  # Widget data bridge
├── Views/
│   ├── LaunchView.swift         # Home screen + onboarding
│   ├── IntentCaptureView.swift  # New anchor form
│   ├── AnchorView.swift         # Live focus session screen
│   ├── ReflectionView.swift     # Session completion + emotional check-in
│   ├── InterruptionView.swift   # Distraction logging
│   ├── ReturnView.swift         # Resume paused session
│   ├── IntentArchiveView.swift  # Journey timeline + insights
│   ├── SettingsView.swift       # User preferences
│   ├── AboutView.swift          # About / Philosophy
│   └── Components/
│       ├── PhilosophyVisualizationView.swift  # 4 philosophy animations
│       ├── HoldToCompleteButton.swift
│       ├── ConfettiView.swift
│       ├── FluidGradientView.swift
│       └── ...
└── MindAnchorWidget/
    ├── MindAnchorLiveActivity.swift  # Lock Screen + Dynamic Island UI
    ├── MindAnchorWidgetProvider.swift # Home Screen widget
    ├── MindAnchorWidgetBundle.swift
    └── FocusActivityAttributes.swift
```

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | Core Data |
| Platform | ActivityKit, WidgetKit, AppIntents |
| Target | iOS 16.2+ |
| Environment | Swift Playgrounds / Xcode |

---

## 🚀 Getting Started

1. Open `MindAnchor.swiftpm` in **Swift Playgrounds 4** or **Xcode 15+**
2. Run on a real device (Live Activities and Haptics require physical hardware)
3. On first launch, choose your Anchor Philosophy (or skip it — no pressure)
4. Tap the circle to set your first intention

---

## 👤 Author

**Vivek Kumar**  
Swift Student Challenge Submission — 2026  

---

## 📄 License

This project is submitted as part of the Apple Swift Student Challenge and is not licensed for redistribution.
