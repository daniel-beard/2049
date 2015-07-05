//
//  GameScene.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // Constants
    let gridStartX = 310
    let gridStartY = 440
    let gridWidth = 100
    let gridHeight = 100
    let gridSize = 4
    let tileTransitionDuration = 0.5
    
    var gameManager: GameManager!
    var gameViewInfo: GameViewInfo?
    var dynamicLabels = [SKLabelNode]()
    
    override func didMoveToView(view: SKView) {
        
        setupGrid()
        gameManager = GameManager(size: gridSize, viewDelegate: self)
        gameManager.restart()
        
        print("\(gameManager.description)")
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
//                case "add":
//                    gameManager.addRandomTile()
//                    print("\(gameManager.description())") 
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
                let centerPosition = gridLabelPositionForPoint(currentPoint)
                let shapeNode = SKShapeNode(rect: currentRect)
                shapeNode.fillColor = .whiteColor()
                shapeNode.strokeColor = .blackColor()
                shapeNode.lineWidth = 2
                self.addChild(shapeNode)
               
                // Set up static labels
                let labelNode = SKLabelNode(text: "")
                decorateLabel(labelNode)
                labelNode.position = centerPosition
                labelNode.name = "\(x)\(y)"
                print(labelNode.name)
                self.addChild(labelNode)
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
        
        self.gameViewInfo = gameViewInfo
        
        // Psuedo code for animations:
        /**
        - Hide all the static labels
        - Create new movable labels over the top.
        - Calculate position diffs and move new labels to the right positions
        - Hide movable labels
        - Show static labels.
        
        */
        
        updateStaticLabels()

        // Create new dynamic labels over the top
        createDynamicLabels(fromTransitions: gameViewInfo.positionTransitions)
        
        
        print(gameViewInfo.positionTransitions)
        
    }
}

//MARK: Static Label Extension
extension GameScene {
    func decorateLabel(label: SKLabelNode) {
        label.zPosition = 100
        label.fontColor = .blackColor()
        label.fontSize = 32
    }
    
    func staticLableNodeAtGridPoint(point: CGPoint) -> SKLabelNode? {
        let labelName = "\(Int(point.x))\(Int(point.y))"
        return self.childNodeWithName(labelName) as? SKLabelNode
    }
    
    func updateStaticLabels() {
        for x in 0..<gridSize {
            for y in 0..<gridSize {
                var text = ""
                if let content = gameViewInfo?.grid.cellContent(Position(x: x, y: y)) {
                    text = "\(content.value)"
                }
                if let labelNode = staticLableNodeAtGridPoint(CGPoint(x: x, y: y)) {
                    labelNode.text = text
                }
            }
        }
    }
    
    func setStaticLabelAlpha(alpha: CGFloat) {
        for x in 0..<gridSize {
            for y in 0..<gridSize {
                if let labelNode = staticLableNodeAtGridPoint(CGPoint(x: x, y: y)) {
                    labelNode.alpha = alpha
                }
            }
        }
    }
}

//MARK: Dynamic Label Extension
extension GameScene {
    func createDynamicLabels(fromTransitions transitions: [PositionTransition]) {
        self.dynamicLabels = [SKLabelNode]()
        
//        if transitions.count > 0 {
//            setStaticLabelAlpha(0)
//        }
        
        var didRunAnimations = false
        var animations = 0
        
        for transition in transitions {
           
            let startPoint = CGPoint(x: transition.originalPosition.x, y: transition.originalPosition.y)
            guard let staticLabel = staticLableNodeAtGridPoint(startPoint) else {
                continue
            }
            
            
            let startingGridPosition = gridLabelPositionForPoint(CGPoint(x: transition.originalPosition.x, y: transition.originalPosition.y))
            let endGridPosition = gridLabelPositionForPoint(CGPoint(x: transition.newPosition.x, y: transition.newPosition.y))
            let labelNode = SKLabelNode(text: staticLabel.text)
            decorateLabel(labelNode)
            labelNode.position = startingGridPosition
            self.addChild(labelNode)
            self.dynamicLabels.append(labelNode)
            
            didRunAnimations = true
            
            animations++
            labelNode.runAction(SKAction.moveTo(endGridPosition, duration: tileTransitionDuration), completion: {
                //self.cleanupDynamicLabels()
            })
        }
        if !didRunAnimations {
//            cleanupDynamicLabels()
        }
        print("Animations: \(animations)")
    }
    
    func cleanupDynamicLabel(labelNode: SKLabelNode) {
        labelNode.removeFromParent()
        dynamicLabels.removeAtIndex(dynamicLabels.indexOf(labelNode)!)
        
//        self.removeChildrenInArray(dynamicLabels)
//        updateStaticLabels()
//        setStaticLabelAlpha(1)
    }

}
