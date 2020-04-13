//
//  Persistence.swift
//  2049
//
//  Created by Daniel Beard on 7/7/15.
//  Copyright © 2015 DanielBeard. All rights reserved.
//

import Foundation

struct Persistence {
    
    static func updateHighScoreIfNeeded(_ newScore: Int) {
        guard newScore > currentHighScore() else { return }
        UserDefaults.standard.set(newScore, forKey: "highscore")
    }

    static func currentHighScore() -> Int {
        UserDefaults.standard.integer(forKey: "highscore")
    }

    static func writeGameState(state: GameManager) {
        let jsonData = try! JSONEncoder().encode(state)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        UserDefaults.standard.set(jsonString, forKey: "gamestate")
    }

    static func savedGameState() -> GameManager? {
        guard let stateString = UserDefaults.standard.string(forKey: "gamestate") else { return nil }
        guard let data = stateString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(GameManager.self, from: data)
    }
}
