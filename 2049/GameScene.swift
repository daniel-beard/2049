//
//  GameScene.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import SpriteKit

func afterDelay(delay: NSTimeInterval, performBlock block:() -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
}

class GameScene: SKScene {
    
    // Constants
    let gridStartX = 310
    let gridStartY = 440
    let gridWidth = 100
    let gridHeight = 100
    let gridSize = 4
    let tileTransitionDuration = 0.3
    let updateDuration = 0.31
    
    // Variables
    var gameManager: GameManagerProtocol!
    var gameViewInfo: GameViewInfo?
    var labelArray: Array2DTyped<SKLabelNode?>!
    var isAnimating = false
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        labelArray = Array2DTyped(cols: gridSize, rows: gridSize, defaultValue: nil)
        gameManager = GameManager(size: gridSize, viewDelegate: self)
        setupGrid()
        gameManager.restart()
        print("\(gameManager.description)")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if isAnimating {
            return
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let node = nodeAtPoint(location)
            if let nodeName = node.name {
                switch nodeName {
                case "up":
                    gameManager.move(0)
                case "down":
                    gameManager.move(2)
                case "right":
                    gameManager.move(1)
                case "left":
                    gameManager.move(3)
                default:
                    break
                }
            }
        }
    }
    
    func setupGrid() {
        for (x, y) in gameManager.grid.gridIndexes() {
            // Setup grid squares
            let currentPoint = CGPoint(x: x, y: y)
            let currentRect = gridElementRectForPoint(currentPoint)
            let shapeNode = SKShapeNode(rect: currentRect)
            shapeNode.fillColor = .whiteColor()
            shapeNode.strokeColor = .blackColor()
            shapeNode.lineWidth = 2
            self.addChild(shapeNode)
        }
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontColor = .whiteColor()
        scoreLabel.fontSize = 32
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: gridLabelPositionForPoint(CGPoint(x: 0, y: gridSize)).y + 10)
        self.addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(text: "High Score: \(HighScoreManager.currentHighScore())")
        highScoreLabel.fontColor = .whiteColor()
        highScoreLabel.fontSize = 32
        let highScorePosition = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y - 35)
        highScoreLabel.position = highScorePosition
        self.addChild(highScoreLabel)
    }
    
    // Returns a CGPoint for a label in the grid given an input point.
    // E.g. (0,0) returns -> TODODB:
    func gridLabelPositionForPoint(point: CGPoint) -> CGPoint {
        let gridElementRect = gridElementRectForPoint(point)
        let centerPosition = CGPoint(x: CGRectGetMidX(gridElementRect), y: CGRectGetMidY(gridElementRect))
        return centerPosition
    }
    
    func gridElementRectForPoint(point: CGPoint) -> CGRect {
        let x = gridStartX + (gridWidth * Int(point.x))
        let y = gridStartY - (gridHeight * Int(point.y))
        return CGRect(x: x, y: y, width: gridWidth, height: gridHeight)
    }
}

//MARK: View Delegate Extension
extension GameScene : GameViewDelegate {
    
    func updateViewState(gameViewInfo: GameViewInfo) {
        isAnimating = true
        
        self.gameViewInfo = gameViewInfo
        
        // Update high score
        if self.gameViewInfo?.terminated ?? false {
            HighScoreManager.updateHighScoreIfNeeded(self.gameViewInfo?.score ?? 0)
            
            //TODODB: Create restart game overlay here...
        }
        
        // Animate moving labels
        for transition in gameViewInfo.positionTransitions where transition.type == .Moved {
            moveLabel(transition)
        }
        
        print(gameViewInfo.positionTransitions)
        
        // Update static labels
        afterDelay(updateDuration, performBlock: {
            self.updateLabels()
            self.isAnimating = false
            self.updateScore(self.gameViewInfo?.score ?? 0)
        })
    }
    
    func moveLabel(transition: PositionTransition) {
        guard let labelNode = labelArray[transition.start.x, transition.start.y] else {
            return
        }
        let endPosition = gridLabelPositionForPoint(CGPoint(x: transition.end.x, y: transition.end.y))
        labelNode.runAction(SKAction.moveTo(endPosition, duration: tileTransitionDuration))
    }
    
    func updateScore(newScore: Int) {
        scoreLabel.text = "Score: \(newScore)"
    }
}

//MARK: Static Label Extension
extension GameScene {
    func decorateLabel(label: SKLabelNode) {
        label.zPosition = 100
        label.fontColor = .blackColor()
        label.fontSize = 32
    }
    
    func updateLabels() {
        for (x, y) in gameManager.grid.gridIndexes() {
            // If we have an existing label, remove it
            if let labelNode = labelArray[x, y] {
                labelNode.removeFromParent()
            }
            labelArray[x, y] = nil
            
            // If we have content, add a new label
            if let content = gameViewInfo?.grid.cellContent(Position(x: x, y: y)) {
                let labelNode = SKLabelNode(text: "\(content.value)")
                labelNode.position = gridLabelPositionForPoint(CGPoint(x: x, y: y))
                decorateLabel(labelNode)
                labelArray[x, y] = labelNode
                self.addChild(labelNode)
            }
        }
    }
}
