//
//  GameScene.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import SpriteKit

func afterDelay(_ delay: TimeInterval, performBlock block:@escaping () -> Void) {
    let dispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: block)
}

class SKNumberNode: SKShapeNode {
    var labelNode: SKLabelNode!

    init(rectOfSize: CGSize, text: String) {
        
        super.init()
        let rect = CGRect(origin: .zero, size: rectOfSize).insetBy(dx: 20, dy: 20)
        self.path = CGPath(roundedRect: rect, cornerWidth: 5, cornerHeight: 5, transform: nil)
        self.fillColor = .gray

        labelNode = SKLabelNode(text: text)
        addChild(labelNode)
        labelNode.zPosition = 100
        labelNode.fontColor = .white
        labelNode.fontSize = 32
        labelNode.position = CGPoint(x: (rect.size.width / 2) + (labelNode.frame.size.width),
                                     y: (rect.size.height / 2) + (labelNode.frame.size.height / 2))
    }

    required init(coder: NSCoder) {
        fatalError("Not implemented")
    }
}

class GameScene: SKScene {
    
    // Constants
    let gridStartX = 310
    let gridStartY = 440
    let gridWidth = 100
    let gridHeight = 100
    let gridSize = 4
    let tileTransitionDuration = 0.2
    let updateDuration = 0.2
    
    // Variables
    var gameManager: GameManagerProtocol!
    var gameViewInfo: GameViewInfo?
    var labelArray: Array2DTyped<SKNumberNode?>!
    var isAnimating = false
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var titleLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        labelArray = Array2DTyped(cols: gridSize, rows: gridSize, defaultValue: nil)
        gameManager = GameManager(size: gridSize, viewDelegate: self)
        setupGrid()
        gameManager.restart()
        print("\(gameManager.description)")
    }
    
    func setupGrid() {

        titleLabel = SKLabelNode(text: "2049")
        titleLabel.fontColor = .white
        titleLabel.fontSize = 60
        titleLabel.fontName = "DamascusBold"
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height - 100)
        self.addChild(titleLabel)

        for (x, y) in gameManager.grid {
            // Setup grid squares
            let currentPoint = CGPoint(x: x, y: y)
            let currentRect = gridElementRectForPoint(currentPoint)
            let shapeNode = SKShapeNode(rect: currentRect)
            shapeNode.fillColor = .white
            shapeNode.strokeColor = .black
            shapeNode.lineWidth = 2
            self.addChild(shapeNode)
        }
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 32
        scoreLabel.position = CGPoint(x: self.frame.midX, y: gridLabelPositionForPoint(CGPoint(x: 0, y: gridSize)).y + 10)
        self.addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(text: "High Score: \(HighScoreManager.currentHighScore())")
        highScoreLabel.fontColor = .white
        highScoreLabel.fontSize = 32
        highScoreLabel.position = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y - 35)
        self.addChild(highScoreLabel)
    }
    
    // Returns a CGPoint for a label in the grid given an input point.
    func gridLabelPositionForPoint(_ point: CGPoint) -> CGPoint {
        let gridElementRect = gridElementRectForPoint(point)
        let centerPosition = CGPoint(x: gridElementRect.midX, y: gridElementRect.midY)
        return centerPosition
    }
    
    func gridElementRectForPoint(_ point: CGPoint) -> CGRect {
        let x = gridStartX + (gridWidth * Int(point.x))
        let y = gridStartY - (gridHeight * Int(point.y))
        return CGRect(x: x, y: y, width: gridWidth, height: gridHeight)
    }
}

//MARK: View Delegate Extension
extension GameScene : GameViewDelegate {
    
    func updateViewState(_ gameViewInfo: GameViewInfo) {

        guard isAnimating == false else { return }

        //TODO: Store and speed up animations if we are currently in progress?

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

    //TODO: Fix, this doesn't animate smoothly, jumps a little bit. Need to center the end point in the grid position.
    func moveLabel(_ transition: PositionTransition) {
        guard let labelNode = labelArray[transition.start.x, transition.start.y] else {
            return
        }
        var endPosition = gridLabelPositionForPoint(CGPoint(x: transition.end.x,
                                                            y: transition.end.y))

        //TODO: This isn't quite right.
        endPosition.x -= (labelNode.frame.size.width / 2)
        endPosition.y -= (labelNode.frame.size.height)

        labelNode.run(SKAction.move(to: endPosition, duration: tileTransitionDuration))
    }
    
    func updateScore(_ newScore: Int) {
        scoreLabel.text = "Score: \(newScore)"
    }
}

//MARK: Static Label Extension
extension GameScene {

    //TODO: Rename this and `labelArray` to numberNodes, or something similar.
    func updateLabels() {
        for (x, y) in gameManager.grid {
            // If we have an existing label, remove it
            if let labelNode = labelArray[x, y] {
                labelNode.removeFromParent()
            }
            labelArray[x, y] = nil
            
            // If we have content, add a new label
            if let content = gameViewInfo?.grid.cellContent(Position(x: x, y: y)) {
                let gridRect = gridElementRectForPoint(CGPoint(x: x, y: y))

                let numberNode = SKNumberNode(rectOfSize: gridRect.size, text: "\(content.value)")
                numberNode.position = gridRect.origin

                labelArray[x, y] = numberNode
                self.addChild(numberNode)
            }
        }
    }
}
