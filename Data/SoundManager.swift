import Foundation
import AVFoundation

class SoundManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var selectedSound: String = "Rain"
    
    let sounds = ["Rain", "White Noise", "Forest", "Stream"]
    
    func toggleSound() {
        if isPlaying {
            stopAudio()
        } else {
            playAudio(named: selectedSound)
        }
    }
    
    func playAudio(named soundName: String) {
        // In a real app, these would be in the asset bundle.
        // For Swift Playgrounds/Preview, we check if the file exists.
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
            print("Sound file \(soundName).mp3 not found")
            // Fallback or just simulate state for UI
            self.selectedSound = soundName
            self.isPlaying = true
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            self.selectedSound = soundName
            self.isPlaying = true
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
            self.isPlaying = false
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        self.isPlaying = false
    }
}
