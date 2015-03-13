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
        
        println("\(gameManager.description())")
        
        gameManager.move(2)
        
        println("\(gameManager.description())")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
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
                    println("\(gameManager.description())") 
                default:
                    break
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    //MARK: View Delegate
    func updateViewState(gameViewInfo: GameViewInfo) {
        self.gameViewInfo = gameViewInfo
    }
}
