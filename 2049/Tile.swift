//
//  Tile.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

public final class Tile: Codable {
    
    var position: Position
    var value: Int
    var previousPosition: Position?
    var mergedFrom: (Tile, Tile)? // Tracks tiles that merged together
    
    init(position: Position, value: Int) {
        self.position = position
        self.value = value
    }

    private enum CodingKeys: String, CodingKey {
        case position, value, previousPosition
    }
    
    public func savePosition() {
        previousPosition = Position(position: position)
    }
    
    public func updatePosition(_ position: Position) {
        self.position.x = position.x
        self.position.y = position.y
    }
}
