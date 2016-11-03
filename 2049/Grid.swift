//
//  Grid.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

public struct Grid: Sequence, IteratorProtocol {
    
    var cells: Array2DTyped<Tile?>
    var size:Int = 0
    
    init(size: Int) {
        self.size = size
        cells = Array2DTyped(cols: size, rows: size, defaultValue: nil)
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
        for (x, y) in self where cells[x, y] == nil {
            availableCells.append(Position(x: x, y: y))
        }
        return availableCells
    }
    
    public func cellsAvailable() -> Bool {
        return availableCells().count > 0
    }
    
    public func cellAvailable(_ cell: Position) -> Bool {
        return !cellOccupied(cell)
    }
    
    public func cellOccupied(_ cell: Position) -> Bool {
        return cellContent(cell) != nil
    }
    
    public func cellContent(_ cell: Position) -> Tile? {
        if withinBounds(cell) {
            return cells[cell.x, cell.y]
        }
        return nil
    }
    
    // Inserts a tile at its position
    public func insertTile(_ tile: Tile) {
        cells[tile.position.x, tile.position.y] = tile
    }
    
    public func removeTile(_ tile: Tile) {
        cells[tile.position.x, tile.position.y] = nil
    }
    
    public func withinBounds(_ position: Position) -> Bool {
        return position.x >= 0 && position.x < size &&
            position.y >= 0 && position.y < size;
    }

    //MARK: GeneratorType
    var currentElement = 0
    mutating public func next() -> (Int, Int)? {
        let curItem = currentElement
        currentElement += 1
        return cells.twoDimensionalIndexFor(curItem)
    }

    //MARK: SequenceType
    public typealias Iterator = Grid
    public func makeIterator() -> Iterator {
        return self
    }
}
