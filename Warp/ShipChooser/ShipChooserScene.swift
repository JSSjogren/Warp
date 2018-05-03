//
//  MenuScene.swift
//  Space Game
//
//  Created by Jarod Sjogren on 4/17/18.
//  Copyright © 2018 Jarod Sjogren. All rights reserved.
//

import SpriteKit

class ShipChooserScene: SKScene {

    var starField:SKEmitterNode!
    
    var menuButtonNode:SKSpriteNode!
    var shuttle:SKSpriteNode!
    var shuttle2:SKSpriteNode!
    var shuttle3:SKSpriteNode!
    var chooseShipLabel:SKLabelNode!
    var selectedShipLine:SKSpriteNode!
    
    override func didMove(to view: SKView)
    {
        chooseShipLabel = self.childNode(withName: "CHOOSE YOUR SHIP") as! SKLabelNode
        chooseShipLabel.position.x = self.size.width / 2
        chooseShipLabel.position.y = self.size.height - 40
        
        starField = self.childNode(withName: "starField") as! SKEmitterNode
        starField.advanceSimulationTime(10)
        
        menuButtonNode = self.childNode(withName:"menuButton") as! SKSpriteNode
        menuButtonNode.position.x = self.size.width / 2
        
        shuttle = SKSpriteNode(imageNamed: "shuttle")
        shuttle.name = "shuttle"
        shuttle.position.x = self.size.width / 5
        shuttle.position.y = self.size.height / 2
        self.addChild(shuttle)
        
        shuttle2 = SKSpriteNode(imageNamed: "shuttle2")
        shuttle2.name = "shuttle2"
        shuttle2.position.x = self.size.width / 2
        shuttle2.position.y = self.size.height / 2
        self.addChild(shuttle2)
        
        shuttle3 = SKSpriteNode(imageNamed: "shuttle3")
        shuttle3.name = "shuttle3"
        shuttle3.position.x = self.size.width - shuttle.size.width
        shuttle3.position.y = self.size.height / 2
        self.addChild(shuttle3)
        
        selectedShipLine = self.childNode(withName: "selectedShipLine") as! SKSpriteNode
        if UserDefaults().string(forKey: "shuttleName") == "shuttle"
        {
            selectedShipLine.position.x = shuttle.position.x
            selectedShipLine.position.y = shuttle.position.y - 30
        }
        else if UserDefaults().string(forKey: "shuttleName") == "shuttle2"
        {
            selectedShipLine.position.x = shuttle2.position.x
            selectedShipLine.position.y = shuttle2.position.y - 30
        }
        else if UserDefaults().string(forKey: "shuttleName") == "shuttle3"
        {
            selectedShipLine.position.x = shuttle3.position.x
            selectedShipLine.position.y = shuttle3.position.y - 30
        }
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
            else if nodesArray.first?.name == "shuttle"
            {
                UserDefaults().set("shuttle", forKey: "shuttleName")
                selectedShipLine.position.x = shuttle.position.x
                selectedShipLine.position.y = shuttle.position.y - 30
            }
            else if nodesArray.first?.name == "shuttle2"
            {
                UserDefaults().set("shuttle2", forKey: "shuttleName")
                selectedShipLine.position.x = shuttle2.position.x
                selectedShipLine.position.y = shuttle2.position.y - 30
            }
            else if nodesArray.first?.name == "shuttle3"
            {
                UserDefaults().set("shuttle3", forKey: "shuttleName")
                selectedShipLine.position.x = shuttle3.position.x
                selectedShipLine.position.y = shuttle3.position.y - 30
            }
            else
            {
                print("else")
            }
        }
        
    }
}
