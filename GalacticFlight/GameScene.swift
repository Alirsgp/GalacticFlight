//
//  GameScene.swift
//  GalacticFlight
//
//  Created by Ali Mohammadian on 8/15/16.
//  Copyright (c) 2016 Alirsgp. All rights reserved.
//

import SpriteKit
import AVFoundation

struct PhysicsCategory {
    static let Rocket : UInt32 = 0x1 << 1
    static let Lava : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var backgroundMusicPlayer = AVAudioPlayer()
    
    var topLava = SKSpriteNode()
    
    
    var Ground = SKSpriteNode()
    var Rocket = SKSpriteNode()
    
    var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    var died = Bool()
    var restartBTN = SKSpriteNode()
    var muteBTN = SKSpriteNode()
    
    
    let scoreLbl = SKLabelNode()
    
    func restartScene() {
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
        
    }
    
    func createScene() {
        
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
            
        }
        
        
        
        
        self.physicsWorld.contactDelegate = self
        
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLbl.text = "\(score)"
        //scoreLbl.fontName = "FlappyBirdy"
        scoreLbl.zPosition = 10
        scoreLbl.fontSize = 60
        
        self.addChild(scoreLbl)
        
        Ground = SKSpriteNode(imageNamed: "Lava")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Lava
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Rocket
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Rocket
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        
        Ground.zPosition = 3
        
        
        self.addChild(Ground)
        
        
        
        Rocket = SKSpriteNode(imageNamed: "Rocket")
        Rocket.size = CGSize(width: 60, height: 70)
        Rocket.position = CGPoint(x: self.frame.width / 2 - Rocket.frame.width, y: self.frame.height / 2)
        
        Rocket.physicsBody = SKPhysicsBody(circleOfRadius: Rocket.frame.height / 2)
        Rocket.physicsBody?.categoryBitMask = PhysicsCategory.Rocket
        Rocket.physicsBody?.collisionBitMask = PhysicsCategory.Lava | PhysicsCategory.Wall
        Rocket.physicsBody?.contactTestBitMask = PhysicsCategory.Lava | PhysicsCategory.Wall | PhysicsCategory.Score
        Rocket.physicsBody?.affectedByGravity = false
        Rocket.physicsBody?.dynamic = true
        
        Rocket.zPosition = 2
        
        
        self.addChild(Rocket)
        
        
        
    }
    
    
    
    
    
    override func didMoveToView(view: SKView) {
        
        createScene()
        MusicPlayer()
        
        
    }
    
    
    
    
    func createBTN() {
        
        restartBTN = SKSpriteNode(imageNamed: "RestartBTN")
        restartBTN.size = CGSizeMake(200, 100)
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        
        restartBTN.runAction(SKAction.scaleTo(1.0, duration: 0.4))
        
        
    }
    
    func newBTN() {
        
        muteBTN = SKSpriteNode(imageNamed: "newMuteBTN")
        muteBTN.size = CGSizeMake(50, 50)
        muteBTN.position = CGPoint(x: self.frame.width + 10, y: self.frame.height + 300)
        muteBTN.zPosition = 7
        muteBTN.setScale(0)
        self.addChild(muteBTN)
        
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Rocket{
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
            
            
        }
            
        else if firstBody.categoryBitMask == PhysicsCategory.Rocket && secondBody.categoryBitMask == PhysicsCategory.Score
        {
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
            
        }
            
        else if firstBody.categoryBitMask == PhysicsCategory.Rocket && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Rocket {
            
            
            
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false {
                died = true
                createBTN()
            }
        }
            
        else if firstBody.categoryBitMask == PhysicsCategory.Rocket && secondBody.categoryBitMask == PhysicsCategory.Lava || firstBody.categoryBitMask == PhysicsCategory.Lava && secondBody.categoryBitMask == PhysicsCategory.Rocket {
            
            
            
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false {
                died = true
                createBTN()
            }
        }
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event:
        UIEvent?) {
            
            
            if gameStarted == false {
                
                gameStarted = true
                
                
                
                Rocket.physicsBody?.affectedByGravity = true
                
                let spawn = SKAction.runBlock({
                    () in
                    
                    self.createWalls()
                    
                })
                
                let delay = SKAction.waitForDuration(2.0)
                let SpawnDelay = SKAction.sequence([spawn, delay])
                let spawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
                self.runAction(spawnDelayForever)
                
                
                let distance = CGFloat(self.frame.width + wallPair.frame.width)
                let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval (0.01 * distance))
                let removePipes = SKAction.removeFromParent()
                moveAndRemove = SKAction.sequence([movePipes, removePipes])
                
                Rocket.physicsBody?.velocity = CGVectorMake(0, 0)
                Rocket.physicsBody?.applyImpulse(CGVectorMake(0, 90))
                
                
                
                
            } else {
                
                if died == true {
                    
                    
                    
                } else {
                    
                    Rocket.physicsBody?.velocity = CGVectorMake(0, 0)
                    Rocket.physicsBody?.applyImpulse(CGVectorMake(0, 90))
                }
            }
            
            
            
            
            for touch in touches {
                let location = touch.locationInNode(self)
                
                if died == true {
                    
                    if restartBTN.containsPoint(location){
                        restartScene()
                    }
                    
                    
                    
                }
                
                
            }
            
    }
    
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        
        scoreNode.size = CGSize(width: 45, height: 45)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Rocket
        
        
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 345)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 345)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Rocket
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Rocket
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Rocket
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Rocket
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        
        
        topWall.zRotation = CGFloat(M_PI)
        
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.addChild(scoreNode)
        
        
        
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
        
        
    }
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            if died == false {
                backgroundMusicPlayer.play()
            } else if died == true {
                if backgroundMusicPlayer.playing {
                    backgroundMusicPlayer.pause()
                }
            }
            
        } catch let error as NSError {
            print(error.description)
        }
        
    }
    
    func MusicPlayer() {
        
        playBackgroundMusic("Eternity.wav")
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
        if gameStarted == true {
            if died == false {
                enumerateChildNodesWithName("background", usingBlock: ({
                    (node, error) in
                    
                    
                    
                    let bg = node as! SKSpriteNode
                    //speed of background
                    bg.position = CGPoint(x: bg.position.x - 0, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                        
                        
                        
                        
                    }
                    
                }))
            }
            
        }
        
        
    }
}