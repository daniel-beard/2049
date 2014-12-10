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
        
//        for i in 0..<1500 {
//            
//            var direction: String = ""
//            switch i%4 {
//            case 0:
//                direction = "up"
//            case 1:
//                direction = "right"
//            case 2:
//                direction = "down"
//            case 3:
//                direction = "left"
//            default:
//                direction = "UNKNOWN"
//                
//            }
//            
//            println("\(gameManager.description())")
//            println("Moved: \(direction), Move Number: \(i)")
//            gameManager.move(i%4)
//            
//            if let gameInfo = gameViewInfo {
//                if gameInfo.terminated {
//                    println("Game terminated!")
//                    break
//                }
//                
//                println("Score updated: \(gameInfo.score)")
//            }
//            
//        }
        
        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!";
//        myLabel.fontSize = 65;
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
//        
//        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
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
    
        
        /*
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
*/
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    //MARK: View Delegate
    func updateViewState(gameViewInfo: GameViewInfo) {
        self.gameViewInfo = gameViewInfo
//        println("Score updated to \(gameViewInfo.score)")
    }
}
