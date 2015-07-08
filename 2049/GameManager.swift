//
//  GameManager.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

protocol GameManagerProtocol : CustomStringConvertible {
    func setup()
    func restart()
    func isGameTerminated() -> Bool
    func move(direction: Int)
    
    var grid: Grid { get }
}

public class GameManager : GameManagerProtocol {
    
    var size: Int = 0
    var score: Int = 0
    var over: Bool = false
    var won: Bool = false
    var keepPlaying: Bool = false
    var grid: Grid = Grid(size: 0)
    let startTiles = 2
    
    // State transitions
    var previousGameState = Grid(size: 0)
    var tileTransitions = [PositionTransition]()
    
    // View delegate
    weak var viewDelegate: GameViewDelegate?
    
    //MARK: Public Methods
    
    init(size: Int, viewDelegate: GameViewDelegate?) {
        self.size = size
        self.viewDelegate = viewDelegate
        grid = Grid(size: size)
    }
    
    public func restart() {
        setup()
    }
    
    // Return true if the game is lost, or has won and the user hasn't kept playing
    public func isGameTerminated() -> Bool {
        return over || (won && !keepPlaying)
    }
    
    public func setup() {
        grid = Grid(size: size)
        score = 0
        over = false
        won = false
        keepPlaying = false
        
        // Add the initial tiles
        addStartTiles()
        updateViewState()
    }
    
    // Move tiles on the grid in the specified direction
    // 0: up, 1: right, 2: down, 3: left
    func move(direction: Int) {
        
        // Store current state
        previousGameState = grid
        tileTransitions = [PositionTransition]()
        
        if isGameTerminated() {
            return
        }
        
        let vector = Vector.getVector(direction)
        let (traversalsX, traversalsY) = buildTraversals(vector)
        var moved = false
        
        // Save the current tile positions and remove merger information
        prepareTiles()
        
        // Traverse the grid in the right direction and move tiles
        for x in traversalsX {
            for y in traversalsY {
                let cell = Position(x: x, y: y)
                
                if let tile = grid.cellContent(cell) {
                    let (farthestPosition, nextPosition) = findFarthestPosition(cell, vector: vector)
                    
                    // Only one merger per row traversal?
                    var didMergeTile = false
                    if let next = grid.cellContent(nextPosition) {
                        if (next.value == tile.value && next.mergedFrom == nil) {
                            let merged = Tile(position: nextPosition, value: tile.value * 2)
                            
                            merged.mergedFrom = (tile, next)
                            
                            grid.insertTile(merged)
                            grid.removeTile(tile)
                            tileTransitions.append(PositionTransition(start: merged.position, end: merged.position, type: .Removed))
                            
                            // Converge the two tiles' positions
                            tile.updatePosition(nextPosition)
                            
                            // Update the score
                            score += merged.value
                            
                            didMergeTile = true
                            
                            // The mighty 2048 tile
                            if (merged.value == 2048) {
                                won = true
                            }
                        }
                    }
                    
                    if !didMergeTile {
                        moveTile(tile, toCell: farthestPosition)
                    }
                    
                    // Tile moved
                    if cell.equals(tile.position) == false {
                        moved = true
                    }
                    
                    if moved && tile.mergedFrom == nil {
                        tileTransitions.append(PositionTransition(start: cell, end: tile.position, type: .Moved))
                    }
                }
            }
        }
        
        if moved {
            addRandomTile()
            
            if !movesAvailable() {
                over = true // Game over!
            }
        }
        
        print("After Move: \(description)")
        updateViewState()
    }
    
    
    //MARK: Internal Methods
    
    // Adds a tile in a random position
    func addRandomTile() {
        if (grid.cellsAvailable()) {
            let value = arc4random_uniform(10) < 9 ? 2 : 4;
            let tile = Tile(position: grid.randomAvailableCell()!, value: value)
            grid.insertTile(tile)
            
            tileTransitions.append(PositionTransition(start: tile.position, end: tile.position, type: .Added))
            
            print("inserted random value: \(value) at position: \(tile.position.description())")
        }
    }

}

//MARK: Private Methods
internal extension GameManager {
    // Set up the initial tiles to start the game with
    func addStartTiles() {
        for _ in 0..<startTiles {
            addRandomTile()
        }
    }
    
    // Save all tile positions and remove merger info
    func prepareTiles() {
        for x in 0..<grid.size {
            for y in 0..<grid.size {
                if let tile = grid.cellContent(Position(x: x, y: y)) {
                    tile.mergedFrom = nil
                    tile.savePosition()
                }
            }
        }
    }
    
    // Move a tile and its representation
    func moveTile(tile: Tile, toCell: Position) {
        grid.cells[tile.position.x, tile.position.y] = nil
        grid.cells[toCell.x, toCell.y] = tile
        tile.updatePosition(toCell)
    }
    
    
    
    // Build a list of positions to traverse in the right order
    func buildTraversals(vector: Vector) -> ([Int], [Int]) {
        var traversalsX = [Int]()
        var traversalsY = [Int]()
        
        for position in 0..<size {
            traversalsX.append(position)
            traversalsY.append(position)
        }
        
        // Always traverse from the farthest cell in the chosen direction
        traversalsX = vector.x == 1 ? Array(traversalsX.reverse()) : traversalsX
        traversalsY = vector.y == 1 ? Array(traversalsY.reverse()) : traversalsY
        
        return (traversalsX, traversalsY)
    }
    
    func findFarthestPosition(cell: Position, vector: Vector) -> (farthest: Position, next: Position) {
        var currentCell = cell
        var previous: Position = Position(x: -1, y: -1)
        
        repeat {
            previous = currentCell
            currentCell = Position(x: previous.x + vector.x, y: previous.y + vector.y)
        } while (grid.withinBounds(currentCell) && grid.cellAvailable(currentCell))
        
        return (previous, currentCell)
    }
    
    func movesAvailable() -> Bool {
        return grid.cellsAvailable() || tileMatchesAvailable()
    }
    
    // Check for available matches between tiles (more expensive check)
    func tileMatchesAvailable() -> Bool {
        for x in 0..<size {
            for y in 0..<size {
                if let tile = grid.cellContent(Position(x: x, y: y)) {
                    for direction in 0..<4 {
                        let vector = Vector.getVector(direction)
                        let cell = Position(x: x + vector.x, y: y + vector.y)
                        if let other = grid.cellContent(cell) where other.value == tile.value {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    //MARK: View Delegate
    func updateViewState() {
        //TODO: Update best score
        let gameViewInfo = GameViewInfo(grid: grid, score: score, won: won, terminated: isGameTerminated(), transitions: tileTransitions)
        viewDelegate?.updateViewState(gameViewInfo)
    }
}

//MARK: Debug Printable
extension GameManager : CustomStringConvertible {
    
    public var description: String {
        var result = "\n"
        for row in 0..<size {
            for column in 0..<size {
                if let gridValue = grid.cellContent(Position(x: column, y: row)) {
                    result = "\(result)\(gridValue.value) "
                } else {
                    result = "\(result)0 "
                }
            }
            result = "\(result)\n"
        }
        return result
    }
}
