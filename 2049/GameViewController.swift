//
//  GameViewController.swift
//  2049
//
//  Created by Daniel Beard on 12/6/14.
//  Copyright (c) 2014 DanielBeard. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : NSString) -> SKNode? {
        if let path = Bundle.main().pathForResource(file as String, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .dataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    var scene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)

            self.scene = scene
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.current().userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

//MARK: Keyboard shortcuts
extension GameViewController {
    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: #selector(self.handleKeyCommand(_:))),
            UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: #selector(self.handleKeyCommand(_:))),
            UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: [], action: #selector(self.handleKeyCommand(_:))),
            UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [], action: #selector(self.handleKeyCommand(_:))),
        ]
    }

    func handleKeyCommand(_ keyCommand: UIKeyCommand) {
        switch keyCommand.input {
        case UIKeyInputUpArrow:
            scene?.gameManager.move(0)
        case UIKeyInputDownArrow:
            scene?.gameManager.move(2)
        case UIKeyInputRightArrow:
            scene?.gameManager.move(1)
        case UIKeyInputLeftArrow:
            scene?.gameManager.move(3)
        default:
            break
        }
    }
}
