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

// The number tile, with a rounded rect around it
final class SKNumberNode: SKShapeNode, Codable {
    var labelNode: SKLabelNode!

    init(rectOfSize: CGSize, text: String) {
        super.init()
        let rect = CGRect(origin: .zero, size: rectOfSize).insetBy(dx: 20, dy: 20)
        self.path = CGPath(roundedRect: rect, cornerWidth: 5, cornerHeight: 5, transform: nil)
        self.fillColor = .orange
        labelNode = SKLabelNode(text: text)
        addChild(labelNode)
        labelNode.zPosition = 100
        labelNode.fontColor = .white
        labelNode.fontName = "DamascusBold"
        labelNode.fontSize = text.count == 1 ? 32 : 20
        if text.count == 1 {
            labelNode.position = CGPoint(x: (rect.size.width),
                                         y: (rect.size.height / 2) + ((labelNode.frame.size.height / 2) - 2))
        } else {
            labelNode.position = CGPoint(x: rect.size.width,
                                         y: rect.size.height - (labelNode.frame.size.height / 2))
        }

    }

    // Dummy Codable conformance, we just want to use this in an Array2DTyped.
    private var _dummy: String = ""
    private enum CodingKeys: String, CodingKey { case _dummy }

    required init(coder: NSCoder) {
        fatalError("Not implemented")
    }
}

// Tappable Label
final class TappableLabel: SKLabelNode {
    var action: (() -> Void)?
    init(action: @escaping () -> Void) {
        super.init()
        self.action = action
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        action?()
    }
}

class GameScene: SKScene {
    
    // Constants
    let gridStartX = 355
    let gridStartY = 440
    let gridWidth = 80
    let gridHeight = 80
    let gridSize = 4
    let tileTransitionDuration = 0.2
    let updateDuration = 0.2
    
    // Variables
    var gameManager: GameManager!
    var gameViewInfo: GameViewInfo?
    var numberTiles: Array2DTyped<SKNumberNode?>!
    var isAnimating = false
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var titleLabel: SKLabelNode!
    var resetLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        numberTiles = Array2DTyped(cols: gridSize, rows: gridSize, defaultValue: nil)
        if let savedGameState = Persistence.savedGameState() {
            gameManager = savedGameState
            gameManager.viewDelegate = self
            setupGrid()
            gameManager.startFromRestoredState()
        } else {
            gameManager = GameManager(size: gridSize, viewDelegate: self)
            setupGrid()
            gameManager.restart()
        }
    }
    
    func setupGrid() {

        titleLabel = SKLabelNode(text: "2049")
        titleLabel.fontColor = .white
        titleLabel.fontSize = 60
        titleLabel.fontName = "DamascusBold"
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height - 100)
        addChild(titleLabel)

        for (x, y) in gameManager.grid {
            // Setup grid squares
            let currentPoint = CGPoint(x: x, y: y)
            let currentRect = gridElementRectForPoint(currentPoint)
            let shapeNode = SKShapeNode(rect: currentRect)
            shapeNode.fillColor = .white
            shapeNode.strokeColor = .black
            shapeNode.lineWidth = 2
            addChild(shapeNode)
        }
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 32
        scoreLabel.fontName = "DamascusRegular"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: gridLabelPositionForPoint(CGPoint(x: 0, y: gridSize)).y + 10)
        addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(text: "High Score: \(Persistence.currentHighScore())")
        highScoreLabel.fontColor = .white
        highScoreLabel.fontSize = 32
        highScoreLabel.fontName = "DamascusRegular"
        highScoreLabel.position = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y - 35)
        addChild(highScoreLabel)

        resetLabel = TappableLabel(action: { [weak self] in
            self?.alertRestartGame()
        })
        resetLabel.text = "RESET"
        resetLabel.fontName = "DamascusBold"
        resetLabel.fontSize = 32
        resetLabel.fontColor = .white
        resetLabel.position = CGPoint(x: scoreLabel.position.x, y: highScoreLabel.position.y - 65)
        addChild(resetLabel)

    }

    func alertRestartGame() {
        let alert = UIAlertController()
        alert.title = "Restart game?"
        alert.addAction(UIAlertAction(title: "Really reset?", style: .destructive, handler: { [weak self] (_) in
            self?.gameManager.restart()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    // Note: Returns center point of the frame!
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
        isAnimating = true
        
        self.gameViewInfo = gameViewInfo
        
        // Game ended
        if self.gameViewInfo?.terminated ?? false {
            //TODODB: Create restart game overlay here...
        }
        
        // Animate moving labels
        for transition in gameViewInfo.positionTransitions where transition.type == .Moved {
            moveTile(transition)
        }

        // Update static labels
        afterDelay(updateDuration, performBlock: {
            self.updateNumberTiles()
            self.isAnimating = false
            self.updateScore(self.gameViewInfo?.score ?? 0)
        })
    }

    func moveTile(_ transition: PositionTransition) {
        guard let node = numberTiles[transition.start.x, transition.start.y] else {
            return
        }
        node.run(SKAction.move(to: gridElementRectForPoint(transition.end.asPoint()).origin,
                               duration: tileTransitionDuration))
    }
    
    func updateScore(_ newScore: Int) {
        // Save game & highscore
        Persistence.writeGameState(state: gameManager)
        Persistence.updateHighScoreIfNeeded(gameManager.score)
        // Update labels
        scoreLabel.text = "Score: \(newScore)"
        highScoreLabel.text = "High Score: \(Persistence.currentHighScore())"
    }
}

extension GameScene {
    func updateNumberTiles() {
        for (x, y) in gameManager.grid {
            // If we have an existing label, remove it
            if let node = numberTiles[x, y] {
                node.removeFromParent()
            }
            numberTiles[x, y] = nil
            
            // If we have content, add a new tile
            if let content = gameViewInfo?.grid.cellContent(Position(x: x, y: y)) {
                let gridRect = gridElementRectForPoint(CGPoint(x: x, y: y))
                let numberNode = SKNumberNode(rectOfSize: gridRect.size, text: "\(content.value)")
                numberNode.position = gridRect.origin
                numberTiles[x, y] = numberNode
                self.addChild(numberNode)
            }
        }
    }
}
