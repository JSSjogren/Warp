//
//  MenuScene.swift
//  Space Game
//
//  Created by Jarod Sjogren on 4/17/18.
//  Copyright © 2018 Jarod Sjogren. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {

    var starField:SKEmitterNode!
    
    var newGameButtonNode:SKSpriteNode!
    var difficultyButtonNode:SKSpriteNode!
    var difficultyLabelNode:SKLabelNode!
    var warpLabelNode:SKLabelNode!
    var shipChooser:SKSpriteNode!
    
    override func didMove(to view: SKView)
    {
        if UserDefaults().string(forKey: "shuttleName") == nil
        {
            print("Defaults")
            UserDefaults().set("shuttle2", forKey: "shuttleName")
        }
        
        print(UserDefaults().string(forKey: "shuttleName"))

        starField = self.childNode(withName: "starField") as! SKEmitterNode
        starField.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName:"newGameButton") as! SKSpriteNode
        newGameButtonNode.position.x = self.size.width / 2
        
        difficultyButtonNode = self.childNode(withName:"difficultyButton") as! SKSpriteNode
        difficultyButtonNode.position.x = self.size.width / 2
        
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as! SKLabelNode
        difficultyLabelNode.position.x = self.size.width / 2
        
        warpLabelNode = self.childNode(withName: "WARP") as! SKLabelNode
        warpLabelNode.position.x = self.size.width / 2
        
        shipChooser = self.childNode(withName: "shipChooser") as! SKSpriteNode
        shipChooser.position.x = self.size.width / 2
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hard")
        {
            difficultyLabelNode.text = "Hard"
        }
        else
        {
            difficultyLabelNode.text = "Easy"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self)
        {
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "newGameButton"
            {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
            else if nodesArray.first?.name == "difficultyButton"
            {
                changeDifficulty()
            }
            else if nodesArray.first?.name == "shipChooser"
            {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let shipChooser = SKScene(fileNamed: "ShipChooserScene") as! ShipChooserScene
                self.view?.presentScene(shipChooser, transition: transition)
            }
        }
    }
    
    func changeDifficulty()
    {
        let userDefaults = UserDefaults.standard
        if difficultyLabelNode.text == "Easy"
        {
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
        }
        else
        {
            difficultyLabelNode.text = "Easy"
            userDefaults.set(false, forKey: "hard")
        }
        userDefaults.synchronize()
    }
}
