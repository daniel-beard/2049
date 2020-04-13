//
//  GameManager.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import Foundation

/// GameManagerProtocol
/// - Used by this class and the DeterminateGameManager class (for testing / debugging).
protocol GameManagerProtocol : CustomStringConvertible {
    func setup()
    func restart()
    func isGameTerminated() -> Bool
    func move(_ direction: Int)
    var grid: Grid { get }
}

/// GameManager - This class holds all the game logic and can run headless, without UI.
/// Takes inputs, changes state and calls delegate methods with updates, that's it.
//TODO: Make this class serializable to/from user defaults.
final class GameManager : GameManagerProtocol, Codable {
    
    var size = 0
    var score = 0
    var over = false
    var won = false
    var keepPlaying = false
    var grid = Grid(size: 0)
    let startTiles = 2
    
    // State transitions
    var previousGameState = Grid(size: 0)
    var tileTransitions = [PositionTransition]()

    // Everything except the viewDelegate, we'll set that after decoding.
    private enum CodingKeys: String, CodingKey {
        case size, score, over, won, keepPlaying, grid, startTiles, previousGameState, tileTransitions
    }
    
    // View delegate
    weak var viewDelegate: GameViewDelegate?
    
    //MARK: Public Methods
    
    init(size: Int, viewDelegate: GameViewDelegate?) {
        self.size = size
        self.viewDelegate = viewDelegate
        grid = Grid(size: size)
    }

    func restart() {
        setup()
    }

    func startFromRestoredState() {
        updateViewState()
    }
    
    // Return true if the game is lost, or has won and the user hasn't kept playing
    func isGameTerminated() -> Bool {
        return over || (won && !keepPlaying)
    }
    
    func setup() {
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
    func move(_ direction: Int) {

        defer { updateViewState() }

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
                let cell = Position(x, y)
                
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
        }
        
        if !movesAvailable() {
            over = true // Game over!
        }
    }
    
    
    //MARK: Internal Methods
    
    // Adds a tile in a random position
    func addRandomTile() {
        if (grid.cellsAvailable()) {
            let value = arc4random_uniform(10) < 9 ? 2 : 4;
            let tile = Tile(position: grid.randomAvailableCell()!, value: value)
            grid.insertTile(tile)
            tileTransitions.append(PositionTransition(start: tile.position, end: tile.position, type: .Added))
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
        grid.forEach { (arg) in
            let (x, y) = arg
            if let tile = grid.cellContent(Position(x, y)) {
                tile.mergedFrom = nil
                tile.savePosition()
            }
        }
    }
    
    // Move a tile and its representation
    func moveTile(_ tile: Tile, toCell: Position) {
        grid.cells[tile.position.x, tile.position.y] = nil
        grid.cells[toCell.x, toCell.y] = tile
        tile.updatePosition(toCell)
    }
    
    
    
    // Build a list of positions to traverse in the right order
    func buildTraversals(_ vector: Vector) -> ([Int], [Int]) {
        var traversalsX = [Int]()
        var traversalsY = [Int]()
        
        for position in 0..<size {
            traversalsX.append(position)
            traversalsY.append(position)
        }
        
        // Always traverse from the farthest cell in the chosen direction
        traversalsX = vector.x == 1 ? Array(traversalsX.reversed()) : traversalsX
        traversalsY = vector.y == 1 ? Array(traversalsY.reversed()) : traversalsY
        
        return (traversalsX, traversalsY)
    }
    
    func findFarthestPosition(_ cell: Position, vector: Vector) -> (farthest: Position, next: Position) {
        var currentCell = cell
        var previous: Position = Position(-1, -1)
        
        repeat {
            previous = currentCell
            currentCell = Position(previous.x + vector.x, previous.y + vector.y)
        } while (grid.withinBounds(currentCell) && grid.cellAvailable(currentCell))
        
        return (previous, currentCell)
    }
    
    func movesAvailable() -> Bool {
        return grid.cellsAvailable() || tileMatchesAvailable()
    }
    
    // Check for available matches between tiles (more expensive check)
    func tileMatchesAvailable() -> Bool {
        for (x, y) in grid {
            if let tile = grid.cellContent(Position(x, y)) {
                for direction in 0..<4 {
                    let vector = Vector.getVector(direction)
                    let cell = Position(x + vector.x, y + vector.y)
                    if let other = grid.cellContent(cell) , other.value == tile.value {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    //MARK: View Delegate
    func updateViewState() {
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
                if let gridValue = grid.cellContent(Position(column, row)) {
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
