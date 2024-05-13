//
//  Haptics.swift
//  Helldivers 2 Assistant
//
//  Created by Leonard Maculo on 5/9/24.
//

import Foundation
import UIKit

class Haptics {
    static let shared = Haptics()
    
    private init() { }
    
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
