//
//  DeterminateGameManager.swift
//  2049
//
//  Created by Daniel Beard on 7/5/15.
//  Copyright © 2015 DanielBeard. All rights reserved.
//

import Foundation

// Not supported right now. Need to make the GameManagerProtocol complete.
/*
final class DeterminateGameManager : GameManager {
    
    var nonRandomTiles = [Tile]()
    
    override init(size: Int, viewDelegate: GameViewDelegate?) {
        super.init(size: size, viewDelegate: viewDelegate)
        
        nonRandomTiles = [
            Tile(position: Position(x: 0, y: 0), value: 2),
            Tile(position: Position(x: 1, y: 0), value: 2),
            Tile(position: Position(x: 2, y: 0), value: 2),
            Tile(position: Position(x: 3, y: 0), value: 2)
        ]
    }

    public required init(from decoder: Decoder) throws {
        fatalError("Not implemented")
    }
    
    override func addRandomTile() {
        if nonRandomTiles.count > 0 {
            let tile = nonRandomTiles.first!
            grid.insertTile(tile)
            nonRandomTiles.remove(at: 0)
            tileTransitions.append(PositionTransition(start: tile.position, end: tile.position, type: .Added))
        }
    }
}
 */
