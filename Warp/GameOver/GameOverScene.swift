//
//  MenuScene.swift
//  Space Game
//
//  Created by Jarod Sjogren on 4/17/18.
//  Copyright © 2018 Jarod Sjogren. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {

    var starField:SKEmitterNode!
    
    var menuButtonNode:SKSpriteNode!
    var spaceGameLabelNode:SKLabelNode!
    var scoreLabelNode:SKLabelNode!
    var highScoreLabelNode:SKLabelNode!
    var newHighScoreLabelNode:SKLabelNode!
    
    var hs1:SKLabelNode!
    var hs2:SKLabelNode!
    var hs3:SKLabelNode!
    var hs4:SKLabelNode!
    var hs5:SKLabelNode!
    
    var score:Int = 0
    
    override func didMove(to view: SKView)
    {
        starField = self.childNode(withName: "starField") as! SKEmitterNode
        starField.advanceSimulationTime(10)
        
        menuButtonNode = self.childNode(withName:"menuButton") as! SKSpriteNode
        menuButtonNode.position.x = self.size.width / 2
        
        spaceGameLabelNode = self.childNode(withName: "GAME OVER") as! SKLabelNode
        spaceGameLabelNode.position.x = self.size.width / 2
        
        scoreLabelNode = self.childNode(withName: "score") as! SKLabelNode
        scoreLabelNode.position.x = self.size.width / 2
        scoreLabelNode.text = "Score: \(score)"
        
        highScoreLabelNode = self.childNode(withName: "HighScoresLabel") as! SKLabelNode
        highScoreLabelNode.position.x = self.size.width / 2
        
        newHighScoreLabelNode = self.childNode(withName: "newHighScoreLabel") as! SKLabelNode
        newHighScoreLabelNode.position.x = self.size.width / 2
        newHighScoreLabelNode.fontColor = UIColor.red
        
        (self.childNode(withName: "line") as! SKSpriteNode).position.x = self.size.width / 2
        
        hs1 = self.childNode(withName: "hs1") as! SKLabelNode
        hs1.text = "1.  \(UserDefaults().integer(forKey:"hs1"))"
        hs1.position.x = self.size.width / 2
        hs2 = self.childNode(withName: "hs2") as! SKLabelNode
        hs2.text = "2.  \(UserDefaults().integer(forKey:"hs2"))"
        hs2.position.x = self.size.width / 2
        hs3 = self.childNode(withName: "hs3") as! SKLabelNode
        hs3.text = "3.  \(UserDefaults().integer(forKey:"hs3"))"
        hs3.position.x = self.size.width / 2
        hs4 = self.childNode(withName: "hs4") as! SKLabelNode
        hs4.text = "4.  \(UserDefaults().integer(forKey:"hs4"))"
        hs4.position.x = self.size.width / 2
        hs5 = self.childNode(withName: "hs5") as! SKLabelNode
        hs5.text = "5.  \(UserDefaults().integer(forKey:"hs5"))"
        hs5.position.x = self.size.width / 2
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self)
        {
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "menuButton"
            {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene
                self.view?.presentScene(menuScene, transition: transition)
            }
        }
    }
}
