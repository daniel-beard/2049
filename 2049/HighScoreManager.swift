//
//  HighScoreManager.swift
//  2049
//
//  Created by Daniel Beard on 7/7/15.
//  Copyright © 2015 DanielBeard. All rights reserved.
//

import Foundation

class HighScoreManager {
    
    static let highScoreKey = "highscore"
    
    class func updateHighScoreIfNeeded(_ newScore: Int) {
        if (newScore > currentHighScore()) {
            UserDefaults.standard().set(newScore, forKey: highScoreKey)
            UserDefaults.standard().synchronize()
        }
    }

    class func currentHighScore() -> Int {
        return UserDefaults.standard().integer(forKey: highScoreKey)
    }
    
}
