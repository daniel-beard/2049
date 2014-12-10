//
//  GameViewDelegate.swift
//  2049
//
//  Created by Daniel Beard on 12/7/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

protocol GameViewDelegate: class {
//    func insertTile(tile: Tile)
//    func moveTile(tile: Tile, toPosition: Position)
    func updateViewState(gameViewInfo: GameViewInfo)
}

public class GameViewInfo {
    var grid: Grid
    var score: Int
    var bestScore: Int
    var won: Bool
    var terminated: Bool
    
    init(grid: Grid, score: Int, bestScore: Int, won: Bool, terminated: Bool) {
        self.grid = grid
        self.score = score
        self.bestScore = bestScore
        self.won = won
        self.terminated = terminated
    }
}