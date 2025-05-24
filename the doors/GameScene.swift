//
//  GameScene.swift
//  the doors
//
//  Created by Yoshua Elmaryono on 18/07/18.
//  Copyright © 2018 Yoshua Elmaryono. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var leftDoor: SKSpriteNode!
    private var rightDoor: SKSpriteNode!
    private var centerDoor: SKSpriteNode!
    private var cameraNode: SKCameraNode!
    private var blackCover: SKShapeNode!
    private var killerComesTimer: Timer!
    private var deathTimer: Timer!
    private var doors_areLocked = false
    
    var gameController: GameController?
    
    override func didMove(to view: SKView) {
        doors_areLocked = false
        
        leftDoor = self.childNode(withName: "leftDoor") as! SKSpriteNode
        rightDoor = self.childNode(withName: "rightDoor") as! SKSpriteNode
        centerDoor = self.childNode(withName: "centerDoor") as! SKSpriteNode
        
        blackCover = self.childNode(withName: "blackCover") as! SKShapeNode
        
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: 0, y: 0)
        self.addChild(cameraNode)
        self.camera = cameraNode

        cameraNode.setScale(1.5)
        blackCover.alpha = 1
        
        let animationDuration = 1.3
        let zoomInAction = SKAction.scale(to: 0.8, duration: animationDuration)
        cameraNode.run(zoomInAction)
        let uncover = SKAction.fadeAlpha(to: 0, duration: animationDuration)
        blackCover.run(uncover)
        
        let delay_toSyncWith_animation = 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay_toSyncWith_animation) {
            self.gameController?.playSFX_playerOpenDoor()
            self.restrictTimeSpent_inRoom()
        }
    }
    
    override func willMove(from view: SKView) {
        invalidateAllTimers()
    }
    
    func restrictTimeSpent_inRoom(){
        invalidateAllTimers()
        setTimers()
    }
    func invalidateAllTimers(){
        if killerComesTimer != nil {
            killerComesTimer.invalidate()
        }
        if deathTimer != nil {
            deathTimer.invalidate()
        }
    }
    func setTimers(){
        let time_whenKillerComes = 7.0
        killerComesTimer = Timer.scheduledTimer(withTimeInterval: time_whenKillerComes, repeats: false) { (timer) in
            self.gameController?.playSFX_killerOpenDoor()
        }
        
        let killerOpenDoor_time = gameController?.getSFXDuration_killerOpenDoor() ?? 3.0
        let gameOverTime = time_whenKillerComes + killerOpenDoor_time + 2.0
        deathTimer = Timer.scheduledTimer(withTimeInterval: gameOverTime, repeats: false, block: { (timer) in
            self.gameController?.gameOver()
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if doors_areLocked { return }
        
        let touch = touches.first!
        let position_inScene = touch.location(in: self)
        let touchedNodes = self.nodes(at: position_inScene)
        
        touchedNodes.forEach { (node) in
            let name = node.name
            switch name {
            case "leftDoor": touchLeftDoor()
            case "centerDoor": touchCenterDoor()
            case "rightDoor": touchRightDoor()
            default: break
            }
        }
    }
    
    //guessDoor must be before enterDoor to avoid bug (doors are not locked when player guess incorrectly)
    private func touchLeftDoor(){
        gameController?.guessLeftDoor()
        enterDoor(leftDoor)
    }
    private func touchCenterDoor(){
        gameController?.guessCenterDoor()
        enterDoor(centerDoor)
    }
    private func touchRightDoor(){
        gameController?.guessRightDoor()
        enterDoor(rightDoor)
    }
    private func enterDoor(_ door: SKNode, duration: TimeInterval = 2.0){
        let zoomInAction = SKAction.scale(to: 0.2, duration: duration)
        let moveCenter_toDoor = SKAction.move(to: door.position, duration: duration)
        
        let enterDoorAnimation = SKAction.group([zoomInAction, moveCenter_toDoor])
        let cover = SKAction.fadeAlpha(to: 1, duration: duration)
        
        blackCover.run(cover)
        cameraNode.run(enterDoorAnimation) {
            self.resetCameraPosition()
        }
        gameController?.playSFX_playerOpenDoor()
        restrictTimeSpent_inRoom()
        
        lockDoors_ifPlayerGuessedIncorrectly()
    }
    private func lockDoors_ifPlayerGuessedIncorrectly(){
        guard let guesses_areCorrect = gameController?.playerGuesses_areCorrect() else {return}
        if guesses_areCorrect == true{
            doors_areLocked = false
        }else{
            doors_areLocked = true
        }
    }
    private func resetCameraPosition(){
        let duration = 0.1
        let zoomOutAction = SKAction.scale(to: 1, duration: duration)
        let centerPosition = CGPoint(x: 0, y: 0)
        let resetCenter = SKAction.move(to: centerPosition, duration: duration)
        
        let resetCameraAnimation = SKAction.group([zoomOutAction, resetCenter])
        let uncover = SKAction.fadeAlpha(to: 0, duration: 1)
        
        blackCover.run(uncover)
        cameraNode.run(resetCameraAnimation)
    }
}
