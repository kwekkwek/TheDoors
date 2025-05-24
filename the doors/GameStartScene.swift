//
//  GameStartScene.swift
//  the doors
//
//  Created by Yoshua Elmaryono on 19/07/18.
//  Copyright © 2018 Yoshua Elmaryono. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameStartScene: SKScene {
    var hints: [DoorGuess]!
    var gameController: GameController?
    
    override func didMove(to view: SKView) {
        print(hints)
        for i in 0..<hints.count{
            addHintSprite(i)
        }
    }
    func addHintSprite(_ index: Int){
        let box: SKSpriteNode = {
            switch hints[index] {
            case .left: return SKSpriteNode(imageNamed: "leftArrow")
            case .center: return SKSpriteNode(imageNamed: "upArrow")
            case .right: return SKSpriteNode(imageNamed: "rightArrow")
            }
        }()
        let boxWidth = Double(box.frame.width)
        let median = getMedianPosition(array: hints)
        let xPosition = ((Double(index) - median) * 60) + (boxWidth / 2)
        box.position = CGPoint(x: xPosition, y: 60)
        box.zPosition = 10
        
        box.name = "box_1"
        addChild(box)
    }
    func getMedianPosition<T> (array: Array<T>) -> Double{
        return Double(array.count) / 2
    }
}
