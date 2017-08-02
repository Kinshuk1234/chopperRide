//
//  GameScene.swift
//  ChopperRide
//
//  Created by Kinshuk Singh on 2017-08-01.
//  Copyright © 2017 Ksk. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var plane = SKSpriteNode()
    var background = SKSpriteNode()
    var ground = SKSpriteNode()
    var mountain = SKSpriteNode()
    var mountain2 = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    var score = 0
    
    var gameOverLabel = SKLabelNode()
    
    var timer = Timer()
    
    enum CollisionType: UInt32 {
    
        case planeType = 1
        case obstacleType = 2 // doubling every time! If there were more cases, then it would go like 1, 2, 4, 8, 16... This is so as to get every combinations of cases
        case gapType = 4
        
    }
    
    var gameOver = false
    
    func makeObstacles() {
    
        // obstacles
        
        let moveObstacles = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        
        let gapHeight = plane.size.height * 4
        
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        
        let obstacleOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        // obstacle 1
        
        let mountainTexture = SKTexture(imageNamed: "mountdown.png")
        
        mountain = SKSpriteNode(texture: mountainTexture)
        
        mountain.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + mountainTexture.size().height / 2 + gapHeight / 2 + obstacleOffset)
        
        mountain.run(moveObstacles)
        
        mountain.physicsBody = SKPhysicsBody(rectangleOf: mountainTexture.size())
        mountain.physicsBody!.isDynamic = false
        
        mountain.physicsBody!.contactTestBitMask = CollisionType.obstacleType.rawValue
        mountain.physicsBody!.categoryBitMask = CollisionType.obstacleType.rawValue
        mountain.physicsBody!.collisionBitMask = CollisionType.obstacleType.rawValue
        
        mountain.zPosition = -1
        
        self.addChild(mountain)
        
        // obstacle 2
        
        let mountainTexture2 = SKTexture(imageNamed: "mountup.png")
        
        mountain2 = SKSpriteNode(texture: mountainTexture2)
        
        mountain2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - mountainTexture2.size().height / 2 - gapHeight / 2 + obstacleOffset)
        
        mountain2.run(moveObstacles)
        
        mountain2.physicsBody = SKPhysicsBody(rectangleOf: mountainTexture.size())
        mountain2.physicsBody!.isDynamic = false
        
        mountain2.physicsBody!.contactTestBitMask = CollisionType.obstacleType.rawValue
        mountain2.physicsBody!.categoryBitMask = CollisionType.obstacleType.rawValue
        mountain2.physicsBody!.collisionBitMask = CollisionType.obstacleType.rawValue
        
        mountain2.zPosition = -1
        
        self.addChild(mountain2)
        
        // gap counts
        
        let gapCount = SKNode()
        
        gapCount.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + obstacleOffset)
        
        gapCount.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: mountainTexture.size().width, height: gapHeight))
        
        gapCount.physicsBody!.isDynamic = false
        
        gapCount.run(moveObstacles)
        
        gapCount.physicsBody!.contactTestBitMask = CollisionType.planeType.rawValue
        gapCount.physicsBody!.categoryBitMask = CollisionType.gapType.rawValue
        gapCount.physicsBody!.collisionBitMask = CollisionType.gapType.rawValue
        
        self.addChild(gapCount)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false {
        
        if contact.bodyA.categoryBitMask == CollisionType.gapType.rawValue || contact.bodyB.categoryBitMask == CollisionType.gapType.rawValue {
            
            score += 1
            
            scoreLabel.text = String(score)
            
        } else {
        
            self.speed = 0
        
            gameOver = true
            
            timer.invalidate()
            
            gameOverLabel.fontName = "Helvetica"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game Over! Tap to play again."
            gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            
            self.addChild(gameOverLabel)
            
        }
            
        }
        
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupNewGame()
        
    }
    
    func setupNewGame() {
    
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makeObstacles), userInfo: nil, repeats: true)
        
        // background
        
        let backgroundTexture = SKTexture(imageNamed: "background.png")
        
        let moveBG = SKAction.move(by: CGVector(dx: -backgroundTexture.size().width, dy: 0), duration: 7)
        let shiftBG = SKAction.move(by: CGVector(dx: backgroundTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBG, shiftBG])) // two animations together
        
        var i: CGFloat = 0
        
        while i < 3 {
            
            background = SKSpriteNode(texture: backgroundTexture)
            
            background.position = CGPoint(x: backgroundTexture.size().width * i, y: self.frame.midY)
            
            background.size.height = self.frame.height
            
            background.run(moveBGForever)
            
            background.zPosition = -2
            
            self.addChild(background)
            
            i += 1
            
        }
        
        // plane
        
        let planeTexture = SKTexture(imageNamed: "plane1.png")
        let planeTexture2 = SKTexture(imageNamed: "plane2.png")
        let planeTexture3 = SKTexture(imageNamed: "plane3.png")
        
        let animation = SKAction.animate(with: [planeTexture, planeTexture2, planeTexture3], timePerFrame: 0.1)
        
        let makePlaneFlap = SKAction.repeatForever(animation)
        
        plane = SKSpriteNode(texture: planeTexture)
        
        plane.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        plane.run(makePlaneFlap)
        
        plane.physicsBody = SKPhysicsBody(circleOfRadius: planeTexture.size().height / 2)
        
        plane.physicsBody!.isDynamic = false
        
        plane.physicsBody!.contactTestBitMask = CollisionType.obstacleType.rawValue
        plane.physicsBody!.categoryBitMask = CollisionType.planeType.rawValue
        plane.physicsBody!.collisionBitMask = CollisionType.planeType.rawValue
        
        self.addChild(plane)
        
        // ground
        
        let groundTexture = SKTexture(imageNamed: "ground.png")
        
        ground = SKSpriteNode(texture: groundTexture)
        
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        
        ground.physicsBody!.isDynamic = false
        
        ground.physicsBody!.contactTestBitMask = CollisionType.obstacleType.rawValue
        ground.physicsBody!.categoryBitMask = CollisionType.obstacleType.rawValue
        ground.physicsBody!.collisionBitMask = CollisionType.obstacleType.rawValue
        
        self.addChild(ground)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        
        self.addChild(scoreLabel)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
        
        plane.physicsBody!.isDynamic = true
        
        plane.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        
        plane.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 100))
            
        } else {
        
            gameOver = false
            score = 0
            self.speed = 1
            
            self.removeAllChildren()
            
            setupNewGame()
            
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

















