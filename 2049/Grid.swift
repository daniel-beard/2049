//
//  Grid.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

public class Grid {
    
    var cells: Array2DTyped<AnyObject>
    var size:Int = 0
    
    init(size: Int) {
        self.size = size
        cells = Array2DTyped(cols: size, rows: size, defaultValue: NSNull())
    }
    
    // Find the first available random position
    public func randomAvailableCell() -> Position? {
        var cellsAvailable = availableCells()
        if cellsAvailable.count > 0 {
            let randomIndex: Int = Int(arc4random_uniform(UInt32(cellsAvailable.count)))
            return cellsAvailable[randomIndex]
        }
        return nil
    }
    
    public func availableCells() -> [Position] {
        var availableCells = [Position]()
        
        for x in 0..<cells.colCount() {
            for y in 0..<cells.rowCount() {
                var value: AnyObject = cells[x, y]
                switch value {
                case let value as NSNull:
                    availableCells.append(Position(x: x, y: y))
                default:
                    break
                }
            }
        }
        return availableCells
    }
    
    public func cellsAvailable() -> Bool {
        return availableCells().count > 0
    }
    
    public func cellAvailable(cell: Position) -> Bool {
        return !cellOccupied(cell)
    }
    
    public func cellOccupied(cell: Position) -> Bool {
        if let content = cellContent(cell) {
            return true
        } else {
            return false
        }
    }
    
    public func cellContent(cell: Position) -> Tile? {
        let tile: AnyObject = _cellContent(cell)
        switch tile {
        case let tile as Tile:
            return tile as Tile
        default:
            return nil
        }
    }
    
    func _cellContent(cell: Position) -> AnyObject {
        if withinBounds(cell) {
            return cells[cell.x, cell.y]
        } else {
            return NSNull()
        }
    }
    
    // Inserts a tile at its position
    public func insertTile(tile: Tile) {
        cells[tile.position.x, tile.position.y] = tile
    }
    
    public func removeTile(tile: Tile) {
        cells[tile.position.x, tile.position.y] = NSNull()
    }
    
    
    public func withinBounds(position: Position) -> Bool {
        return position.x >= 0 && position.x < size &&
            position.y >= 0 && position.y < size;
    }
}