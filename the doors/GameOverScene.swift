//
//  GameOverScene.swift
//  the doors
//
//  Created by Yoshua Elmaryono on 18/07/18.
//  Copyright © 2018 Yoshua Elmaryono. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameOverScene: SKScene {
    private var gameOverWall: SKSpriteNode!
    private var blackCover: SKShapeNode!
    private var deathBlood: SKSpriteNode!
    private var impendingDeath_SFXArray: [AVAudioPlayer] = []
    private var death_SFXArray: [AVAudioPlayer] = []
    var gameController: GameController?
    private var enableReplayingGame = false
    private var img1: SKSpriteNode = SKSpriteNode(imageNamed: "blood1")
    private var img2: SKSpriteNode = SKSpriteNode(imageNamed: "blood2")
    private var img3: SKSpriteNode = SKSpriteNode(imageNamed: "blood3")
    private var img4: SKSpriteNode = SKSpriteNode(imageNamed: "blood4")
    
    
    override func didMove(to view: SKView) {
        enableReplayingGame = false
        
        blackCover = self.childNode(withName: "blackCover") as! SKShapeNode
        gameOverWall = self.childNode(withName: "gameOverWall") as! SKSpriteNode
        deathBlood = self.childNode(withName: "deathBlood") as! SKSpriteNode
        deathBlood.alpha = 0
        
        loadImpendingDeathSFXS()
        loadDeathSFXS()
        
        let glitchInterval = 1.0
        glitchScreen(interval: glitchInterval)
        
        let impendingDeathDelay = glitchInterval + 0.5
        Timer.scheduledTimer(withTimeInterval: impendingDeathDelay, repeats: false) { (timer) in
            self.playImpendingDeathSFXS()
        }
        
        let deathDelay = impendingDeathDelay + 3.0
        Timer.scheduledTimer(withTimeInterval: deathDelay, repeats: false) { (timer) in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            self.deathBlood.alpha = 1
            self.playDeathSFXS()
        }
        
        let longestDeathSFX_duration: Double = {
            let sfxs_duration: [Double] = death_SFXArray.map({ (sfx) -> Double in sfx.duration })
            return sfxs_duration.max()!
        }()
        let enableReplayGame_delay = deathDelay + longestDeathSFX_duration + 1.0
        Timer.scheduledTimer(withTimeInterval: enableReplayGame_delay, repeats: false) { (timer) in
            self.enableReplayingGame = true
        }
    }
    
    private func glitchScreen(interval glitchInterval: Double){
        let blinkInterval = 0.1
        let glitchTimer = Timer.scheduledTimer(withTimeInterval: blinkInterval, repeats: true) { (timer) in
            self.blackCover.alpha = 1
            let uncover = SKAction.fadeAlpha(to: 0, duration: 0.001)
            self.blackCover.run(uncover)
        }
        
        Timer.scheduledTimer(withTimeInterval: glitchInterval, repeats: false) { (timer) in
            glitchTimer.invalidate()
            self.blackCover.alpha = 0
        }
    }
    func loadImpendingDeathSFXS(){
        do {
            
            let objectBroken_SFXData = NSDataAsset(name: "objectBrokenSFX")!.data
            let objectBrokenSFX = try AVAudioPlayer(data: objectBroken_SFXData, fileTypeHint: AVFileType.mp3.rawValue)
            
            let heartBeat_SFXData = NSDataAsset(name: "heartBeatSFX")!.data
            let heartBeatSFX = try AVAudioPlayer(data: heartBeat_SFXData, fileTypeHint: AVFileType.mp3.rawValue)
            
            impendingDeath_SFXArray = [objectBrokenSFX, heartBeatSFX]
        } catch {
            print(error.localizedDescription)
        }
    }
    func playImpendingDeathSFXS(){
        impendingDeath_SFXArray.forEach { (sfx) in sfx.play() }
    }
    func loadDeathSFXS(){
        do {
            let deathScream_SFXData = NSDataAsset(name: "deathScreamSFX")!.data
            let deathScreamSFX = try AVAudioPlayer(data: deathScream_SFXData, fileTypeHint: AVFileType.mp3.rawValue)
      
            let intro_SFXData = NSDataAsset(name: "introSFX")!.data
            let introSFX = try AVAudioPlayer(data: intro_SFXData, fileTypeHint: AVFileType.mp3.rawValue)
            
            death_SFXArray = [deathScreamSFX, introSFX]
        } catch {
            print(error.localizedDescription)
        }
    }
    func playDeathSFXS(){
        impendingDeath_SFXArray.forEach { (sfx) in
            if sfx.isPlaying {
                sfx.setVolume(0, fadeDuration: 0.5)
            }
        }
        
        death_SFXArray.forEach { (sfx) in sfx.play() }
        gameController?.stopBGM()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let position_inScene = touch.location(in: self)
        let touchedNodes = self.nodes(at: position_inScene)
        
        touchedNodes.forEach { (node) in
            let name = node.name
            switch name {
            case "gameOverWall": if enableReplayingGame { gameController?.startGame() }
            default: break
            }
        }
    }
}
