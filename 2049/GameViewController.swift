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
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
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

        setupSwipeHandlers()
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK: Keyboard shortcuts
extension GameViewController {
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: UIKeyInputUpArrow,      modifierFlags: [], action: #selector(swipeUp)),
            UIKeyCommand(input: UIKeyInputDownArrow,    modifierFlags: [], action: #selector(swipeDown)),
            UIKeyCommand(input: UIKeyInputLeftArrow,    modifierFlags: [], action: #selector(swipeLeft)),
            UIKeyCommand(input: UIKeyInputRightArrow,   modifierFlags: [], action: #selector(swipeRight)),
        ]
    }

    func setupSwipeHandlers() {
        let leftSwipe   = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))  
        let rightSwipe  = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight)) 
        let upSwipe     = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        let downSwipe   = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        leftSwipe.direction     = .left
        rightSwipe.direction    = .right
        upSwipe.direction       = .up
        downSwipe.direction     = .down
        self.view.gestureRecognizers = [leftSwipe, rightSwipe, upSwipe, downSwipe]
    }

    @objc func swipeLeft()    { scene?.gameManager.move(3) }
    @objc func swipeRight()   { scene?.gameManager.move(1) }
    @objc func swipeUp()      { scene?.gameManager.move(0) }
    @objc func swipeDown()    { scene?.gameManager.move(2) }
}
