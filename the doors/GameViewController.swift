//
//  GameViewController.swift
//  the doors
//
//  Created by Yoshua Elmaryono on 18/07/18.
//  Copyright © 2018 Yoshua Elmaryono. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

enum DoorGuess: Int {
    case left, center, right
    
    static func randomGuess() -> DoorGuess {
        let possibleDoorGuess: UInt32 = 3  //because there are only 3 doors
        let value = Int(arc4random_uniform(possibleDoorGuess))
        let door = DoorGuess(rawValue: value)
        
        return door!
    }
}

class GameViewController: UIViewController {
    private var bgmPlayer: AVAudioPlayer!
    private var introSFX: AVAudioPlayer!
    private var playerOpenDoorSFX: AVAudioPlayer!
    private var killerOpenDoorSFX: AVAudioPlayer!
    private var correctGuesses: [DoorGuess]! = []
    private var playerGuesses: [DoorGuess]! = []
    private var round = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPlayerForBGM()
        loadPlayerForSoundEffect()
        
        startGame()
    }
    func startGame(){
        print("Game Start")
        
        let infinity = -1
        bgmPlayer.numberOfLoops = infinity
        bgmPlayer.volume = 0.01
        bgmPlayer.play()
        bgmPlayer.setVolume(0.5, fadeDuration: 20)
        
        introSFX.play()
        
        round = 1
        startRound(round)
    }
    func loadPlayerForBGM(){
        guard let backgroundMusicData = NSDataAsset(name: "bgm")?.data else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. */
            bgmPlayer = try AVAudioPlayer(data: backgroundMusicData, fileTypeHint: AVFileType.mp3.rawValue)
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
        } catch {
            print(error.localizedDescription)
        }
    }
    func loadPlayerForSoundEffect(){
        do {
            let introSFXData = NSDataAsset(name: "introSFX")!.data
            introSFX = try AVAudioPlayer(data: introSFXData, fileTypeHint: AVFileType.mp3.rawValue)
            
            let playerOpenDoorSFXData = NSDataAsset(name: "playerOpenDoorSFX")!.data
            playerOpenDoorSFX = try AVAudioPlayer(data: playerOpenDoorSFXData, fileTypeHint: AVFileType.mp3.rawValue)
            
            let killerOpenDoorSFXData = NSDataAsset(name: "killerOpenDoorSFX")!.data
            killerOpenDoorSFX = try AVAudioPlayer(data: killerOpenDoorSFXData, fileTypeHint: AVFileType.mp3.rawValue)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startRound(_ round: Int){
        let initialGuess = 5
        let totalGuesses: Int = {
            switch round {
            case 0...1: return initialGuess
            case 2...3: return initialGuess + 2
            default: return initialGuess + 5
            }
        }()
        fill_rightGuesses(totalGuesses: totalGuesses)
        
        goTo_startScene()
        
        var delay: Double {
            switch round {
            case 0...3: return 5.0
            case 3...5: return 4.0
            default: return 3.0
            }
        }
        goTo_gameScene(delay: delay)
    }
    func fill_rightGuesses(totalGuesses: Int){
        correctGuesses = []
        for _ in 0..<totalGuesses {
            let door = DoorGuess.randomGuess()
            correctGuesses.append(door)
        }
    }
    func goTo_startScene(){
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let filename = "GameStartScene"
            guard let scene = GameStartScene(fileNamed: filename) else {
                fatalError("\(filename) not found!")
            }
            
            scene.scaleMode = .aspectFill   // Set the scale mode to scale to fit the window
            
            scene.gameController = self
            scene.hints = correctGuesses
            
            let revealScene = SKTransition.fade(withDuration: 3)
            view.presentScene(scene, transition: revealScene)
            
            view.ignoresSiblingOrder = true
        }
    }
    func goTo_gameScene(delay: Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.goTo_gameScene()
        }
    }
    func goTo_gameScene(){
        playerGuesses.removeAll()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let filename = "GameScene"
            guard let scene = GameScene(fileNamed: filename) else {
                fatalError("\(filename) not found!")
            }
            
            scene.scaleMode = .aspectFill   // Set the scale mode to scale to fit the window
            scene.gameController = self
            
            let revealScene = SKTransition.fade(withDuration: 2)
            view.presentScene(scene, transition: revealScene)
            
            view.ignoresSiblingOrder = true
        }
    }
    func goTo_gameOverScene(){
        playerGuesses.removeAll()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameOverScene.sks'
            let filename = "GameOverScene"
            guard let scene = GameOverScene(fileNamed: filename) else {
                fatalError("\(filename) not found!")
            }

            scene.scaleMode = .aspectFill   // Set the scale mode to scale to fit the window
            scene.gameController = self
            
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
        }
    }
    
    //MARK: Display Settings
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

protocol GameController {
    func startGame()
    func gameOver()
    
    func guessLeftDoor()
    func guessRightDoor()
    func guessCenterDoor()
    func playerGuesses_areCorrect() -> Bool
    
    func playSFX_playerOpenDoor()
    func playSFX_killerOpenDoor()
    func getSFXDuration_killerOpenDoor() -> TimeInterval
    func stopBGM()
}
extension GameViewController: GameController {
    func gameOver(){
        print("Game Over")
        goTo_gameOverScene()
    }

    func guessLeftDoor() { guessDoor(.left) }
    func guessCenterDoor() { guessDoor(.center) }
    func guessRightDoor() { guessDoor(.right) }
    
    func guessDoor(_ door: DoorGuess){
        playerGuesses.append(door)
        
        let allGuesses_areCorrect = playerGuesses == correctGuesses
        if(allGuesses_areCorrect){
            goToNextRound()
        }
    }
    func goToNextRound(){
        round += 1
        startRound(round)
    }
    func playerGuesses_areCorrect() -> Bool{
        for i in 0..<playerGuesses.count {
            if playerGuesses[i] != correctGuesses[i] {
                return false
            }
        }
        return true
    }
    
    func playSFX_playerOpenDoor(){
        playerOpenDoorSFX.play()
    }
    func playSFX_killerOpenDoor() {
        killerOpenDoorSFX.play()
    }
    func getSFXDuration_killerOpenDoor() -> TimeInterval {
        return killerOpenDoorSFX.duration
    }
    func stopBGM() {
        bgmPlayer.stop()
    }
}

