//
//  Sound.swift
//  Helldivers 2 Assistant
//
//  Created by Leonard Maculo on 5/9/24.
//

import Foundation
import AVFoundation

class Sounds {
    static var audioPlayer: AVAudioPlayer?
    
    static func playSounds(soundfile: String) {
        if let path = Bundle.main.path(forResource: soundfile, ofType: nil){
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error")
            }
        }
    }
}
