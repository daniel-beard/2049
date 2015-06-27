//
//  GameScene.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, GameViewDelegate {
    
    var gameManager: GameManager = GameManager(size: 4)
    var gameViewInfo: GameViewInfo?
    
    override func didMoveToView(view: SKView) {
        
        gameManager.viewDelegate = self
        setupGrid()
        
        gameManager.move(2)
        print("\(gameManager.description())")
        
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
                case "add":
                    gameManager.addRandomTile()
                    print("\(gameManager.description())") 
                default:
                    break
                }
            }
        }
    }
    
    func setupGrid() {
        let startX = 310
        let startY = 440
        let width = 100
        let height = 100
        for x in 0..<4 {
            for y in 0..<4 {
                let currentX = startX + (width * x)
                let currentY = startY - (height * y)
                let currentRect = CGRect(x: currentX, y: currentY, width: width, height: height)
                let centerPosition = CGPoint(x: CGRectGetMidX(currentRect), y: CGRectGetMidY(currentRect))
                let shapeNode = SKShapeNode(rect: currentRect)
                shapeNode.fillColor = .whiteColor()
                shapeNode.strokeColor = .blackColor()
                shapeNode.lineWidth = 2
                self.addChild(shapeNode)
               
                let labelNode = SKLabelNode(text: "0")
                labelNode.zPosition = 100
                labelNode.fontColor = .blackColor()
                labelNode.fontSize = 32
                labelNode.position = centerPosition
                labelNode.name = "\(x)\(y)"
                print(labelNode.position)
                self.addChild(labelNode)
            }
        }
    }
    
    
    func updateLabels() {
        for x in 0..<4 {
            for y in 0..<4 {
                var text = "0"
                if let content = gameViewInfo?.grid.cellContent(Position(x: x, y: y)) {
                    text = "\(content.value)"
                }
                if let labelNode = self.childNodeWithName("\(x)\(y)") as? SKLabelNode {
                    labelNode.text = text
                }
            }
        }
    }
    
    //MARK: View Delegate
    func updateViewState(gameViewInfo: GameViewInfo) {
        self.gameViewInfo = gameViewInfo
        updateLabels()
    }
}
