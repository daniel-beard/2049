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
    let tileTransitionDuration = 0.5
    let updateDuration = 0.51
    
    var gameManager: GameManagerProtocol!
    var gameViewInfo: GameViewInfo?
    var labelArray: Array2DOptional<SKLabelNode>!
    var isAnimating = false
    
    override func didMoveToView(view: SKView) {
        
        labelArray = Array2DOptional(cols: gridSize, rows: gridSize, defaultValue: nil)
        
        setupGrid()
        gameManager = GameManager(size: gridSize, viewDelegate: self)
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
        for x in 0..<gridSize {
            for y in 0..<gridSize {
                // Setup grid squares
                let currentPoint = CGPoint(x: x, y: y)
                let currentRect = gridElementRectForPoint(currentPoint)
                let shapeNode = SKShapeNode(rect: currentRect)
                shapeNode.fillColor = .whiteColor()
                shapeNode.strokeColor = .blackColor()
                shapeNode.lineWidth = 2
                self.addChild(shapeNode)
            }
        }
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
        
        for transition in gameViewInfo.positionTransitions where transition.type == .Moved {
            moveLabel(transition)
        }
        
        print(gameViewInfo.positionTransitions)
        
        afterDelay(updateDuration, performBlock: {
            self.updateLabels()
            self.isAnimating = false
        })
    }
    
    func moveLabel(transition: PositionTransition) {
        guard let labelNode = labelArray[transition.start.x, transition.start.y] else {
            return
        }
        let endPosition = gridLabelPositionForPoint(CGPoint(x: transition.end.x, y: transition.end.y))
        labelNode.runAction(SKAction.moveTo(endPosition, duration: tileTransitionDuration))
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
        for x in 0..<gridSize {
            for y in 0..<gridSize {
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
}
