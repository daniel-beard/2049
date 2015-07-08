//
//  GameViewDelegate.swift
//  2049
//
//  Created by Daniel Beard on 12/7/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

protocol GameViewDelegate: class {
    func updateViewState(gameViewInfo: GameViewInfo)
}

public class GameViewInfo {
    var grid: Grid
    var score: Int
    var won: Bool
    var terminated: Bool
    var positionTransitions = [PositionTransition]()
    
    init(grid: Grid, score: Int, won: Bool, terminated: Bool, transitions: [PositionTransition]) {
        self.grid = grid
        self.score = score
        self.won = won
        self.terminated = terminated
        self.positionTransitions = transitions
    }
}