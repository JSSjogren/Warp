//
//  GameScene.swift
//  Space Game
//
//  Created by Jarod Sjogren on 4/12/18.
//  Copyright © 2018 Jarod Sjogren. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField:SKEmitterNode!
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var gameTimer:Timer!
    
    var possibleAliens = ["alien", "alien2", "alien3"]
    
    var shipCategory:UInt32 = 0x1 << 2
    var alienCategory:UInt32 = 0x1 << 1
    var photonTorpedoCategory:UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    var livesArray:[SKSpriteNode]!
    
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        addLives()
        
        //Setting up the star field and essentially starting it 10 seconds in so it looks like it has been there the whole time
        starField = SKEmitterNode(fileNamed: "Starfield.sks")
        //Non-dynamic position as of right now
        starField.position = CGPoint(x: self.frame.size.width / 2, y: 1472)
        starField.advanceSimulationTime(10)
        //Make sure it's BEHIND all other nodes
        starField.zPosition = -1
        self.addChild(starField)
        
        //Create the player's shuttle and set it to the bottom center of the screen to start with
        player = SKSpriteNode(imageNamed: UserDefaults().string(forKey:"shuttleName")!)
        //Non-dynamic position as of right now
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 20)
        
        //Setting physicsBodies
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        //Setting the bitmasks for contact checks
        player.physicsBody?.categoryBitMask = shipCategory
        player.physicsBody?.contactTestBitMask = alienCategory
        player.physicsBody?.collisionBitMask = 0
        self.addChild(player)
        
        //Setting gravity to 0 and setting our app to be a physicsworld contactDelegate
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        //Creating the score label and initializing it to 0
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 80, y: self.frame.size.height - 70)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel)
        
        //Set the time interval aliens are spawned at based on difficulty
        var timeInterval = 0.75
        if UserDefaults.standard.bool(forKey: "hard")
        {
            timeInterval = 0.3
        }
        
        //Creating a game timer in which "addAlien" is called every 0.75 seconds on Easy and 0.3 on hard
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: Selector("addAlien"), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!)
        {
            (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }
    
    func addLives()
    {
        livesArray = [SKSpriteNode]()
        for live in 1 ... 3 {
            let liveNode = SKSpriteNode(imageNamed: UserDefaults().string(forKey:"shuttleName")!)
            liveNode.position = CGPoint(x: self.frame.size.width - CGFloat(4 - live) * liveNode.size.width, y: self.frame.size.height - 60)
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }
    
    @objc func addAlien()
    {
        //Essentially randomizing possibleAliens so that possibleAliens[0] doesn't produce the same thing every time
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])

        //Creates a random location for the alien to spawn in
        let alienPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.size.width))
        let position = CGFloat(alienPosition.nextInt())
        alien.position = CGPoint(x: position, y: self.size.height + alien.size.height)
        
        //Creates the physics body for the alien and allows it to interact with the physicsWorld
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        //Setting the bitmasks for contact checks
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        //Adding to view
        self.addChild(alien)
        
        //Aliens stay on the screen for 6 seconds (gives ample time to shoot at them)
        let animationDuration:TimeInterval = 6

        //Creating an array of all active aliens and setting their residence to animationDuration
        //whereafter they'll be removed from view & this array
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        //Running these actions
        alien.run(SKAction.sequence(actionArray))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        //Deciding which body is first and which is second (will make more sense in a second
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //Bitwise AND returns 1 when the two are the same and 0 when they're not the same. By doing thise we're able to check the "type" of the physics bodies that have collided.
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0
        {
            torpedoDidCollideWithAlien(torpedo: firstBody.node as! SKSpriteNode, alien: secondBody.node as! SKSpriteNode)
        }
        else if (firstBody.categoryBitMask & alienCategory) != 0 && (secondBody.categoryBitMask & photonTorpedoCategory) != 0
        {
            torpedoDidCollideWithAlien(torpedo: secondBody.node as! SKSpriteNode, alien: firstBody.node as! SKSpriteNode)
        }
        else if (firstBody.categoryBitMask & shipCategory) != 0 &&
            (secondBody.categoryBitMask & alienCategory) != 0
        {
            print("Collide")
            alienDidCollideWithShip(ship: firstBody.node as! SKSpriteNode, alien: secondBody.node as! SKSpriteNode)
        }
        else if (secondBody.categoryBitMask & shipCategory) != 0 &&
            (firstBody.categoryBitMask & alienCategory) != 0
        {
            alienDidCollideWithShip(ship: secondBody.node as! SKSpriteNode, alien: firstBody.node as! SKSpriteNode)
        }
    }
    
    func torpedoDidCollideWithAlien(torpedo:SKSpriteNode, alien:SKSpriteNode)
    {
        //Create an explosion SKEmitterNode at the alien's position then add the SKEmitterNode to the view
        let explosion = SKEmitterNode(fileNamed: "Explosion")
        explosion?.position = alien.position
        self.addChild(explosion!)
        
        //Play the sound but don't "pause" the game to do so
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        //Torpedo & Alien are now destroyed. Remove from view.
        torpedo.removeFromParent()
        alien.removeFromParent()
        
        //We want the explosion to actually be visible, so we remove it AFTER 2 seconds.
        self.run(SKAction.wait(forDuration: 2))
        {
            explosion?.removeFromParent()
        }
        
        //SCORE +5!
        score += 5
    }
    
    func alienDidCollideWithShip(ship:SKSpriteNode, alien:SKSpriteNode)
    {
        //Create an explosion SKEmitterNode at the alien's position then add the SKEmitterNode to the view
        let explosion = SKEmitterNode(fileNamed: "Explosion")
        explosion?.position = alien.position
        self.addChild(explosion!)
        
        //Play the sound but don't "pause" the game to do so
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        //Alien is now destroyed. Remove from view.
        alien.removeFromParent()
        
        //We want the explosion to actually be visible, so we remove it AFTER 2 seconds.
        self.run(SKAction.wait(forDuration: 2))
        {
            explosion?.removeFromParent()
        }
        
        if self.livesArray.count > 0
        {
            let liveNode = self.livesArray.first
            liveNode?.removeFromParent()
            self.livesArray.removeFirst()
            
            if self.livesArray.count == 0
            {
                let highScore = playerScoreUpdate()
                //GameOverScene transition
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                gameOver.score = self.score
                self.view?.presentScene(gameOver, transition: transition)
                gameOver.newHighScoreLabelNode.text = highScore
            }
        }
    }
    
    func playerScoreUpdate() -> String {
        let hs1 = UserDefaults().integer(forKey:"hs1")
        let hs2 = UserDefaults().integer(forKey:"hs2")
        let hs3 = UserDefaults().integer(forKey:"hs3")
        let hs4 = UserDefaults().integer(forKey:"hs4")
        let hs5 = UserDefaults().integer(forKey:"hs5")
        if score > hs1 {
            UserDefaults().set(UserDefaults().integer(forKey:"hs4"), forKey: "hs5")
            UserDefaults().set(UserDefaults().integer(forKey:"hs3"), forKey: "hs4")
            UserDefaults().set(UserDefaults().integer(forKey:"hs2"), forKey: "hs3")
            UserDefaults().set(UserDefaults().integer(forKey:"hs1"), forKey: "hs2")
            UserDefaults().set(score, forKey: "hs1")
            return "NEW HIGH SCORE: 1ST"
        }
        else if score > hs2 {
            UserDefaults().set(UserDefaults().integer(forKey:"hs4"), forKey: "hs5")
            UserDefaults().set(UserDefaults().integer(forKey:"hs3"), forKey: "hs4")
            UserDefaults().set(UserDefaults().integer(forKey:"hs2"), forKey: "hs3")
            UserDefaults().set(score, forKey: "hs2")
            return "NEW HIGH SCORE: 2ND"
        }
        else if score > hs3 {
            UserDefaults().set(UserDefaults().integer(forKey:"hs4"), forKey: "hs5")
            UserDefaults().set(UserDefaults().integer(forKey:"hs3"), forKey: "hs4")
            UserDefaults().set(score, forKey: "hs3")
            return "NEW HIGH SCORE: 3RD"
        }
        else if score > hs4 {
            UserDefaults().set(UserDefaults().integer(forKey:"hs4"), forKey: "hs5")
            UserDefaults().set(score, forKey: "hs4")
            return "NEW HIGH SCORE: 4TH"
        }
        else if score > hs5 {
            UserDefaults().set(score, forKey: "hs5")
            return "NEW HIGH SCORE: 5TH"
        }
        else
        {
            return ""
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Player has tapped. FIRE TORPEDO!
        fireTorpedo()
    }
    
    func fireTorpedo()
    {
        //Play a sound but don't "pause" the app to play it
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        //Create the torpedo node and set its position to the player's ship
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        
        //Create a physics body and tell it that it's movable by the physics simulation (isDynamic = true)
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        
        //Adding bitmasks to the torpedo physics body so that we can differentiate between the bodies on collision
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        
        //Self explanitory
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        //Adding the torpedo to the view
        self.addChild(torpedoNode)
        
        //The torpedo will take 0.3 seconds to travel across the screen
        let animationDuration:TimeInterval = 0.3
       
        //Creating an array of basically all active torpedos and their durations. They'll be removed from the array and the view after animationDuration
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        //Run the torpedo action
        torpedoNode.run(SKAction.sequence(actionArray))
        
        
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20
        {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }
        else if player.position.x > self.size.width + 20
        {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
