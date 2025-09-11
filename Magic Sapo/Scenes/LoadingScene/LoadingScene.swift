//
//  LoadingScene.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 11/09/25.
//

// LoadingScene.swift - COM BACKGROUND E TEXTO "CROAK!"
import SpriteKit

class LoadingScene: SKScene {

    weak var gameViewController: GameViewController?

    private var isGameCenterReady = false
    private var hasMinimumTimePassed = false

    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupBackground()
        setupCroakText()
        setupLoadingAnimation()
        
        startMinimumTimeTimer()
        authenticateAndProceed()
    }
    
    func setupBackground() {
        let backgroundTextureName = DeviceHelper.isIPhone ? "loadingIphone" : "loadingIpad"
        let backgroundTexture = SKTexture(imageNamed: backgroundTextureName)
        backgroundTexture.filteringMode = .nearest
        
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundNode.size = self.size
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
    }
    
    func setupCroakText() {
        let croakTexture = SKTexture(imageNamed: "croak_iphone")
        croakTexture.filteringMode = .nearest
        
        let croakNode = SKSpriteNode(texture: croakTexture)
        
        if DeviceHelper.isIPhone {
            croakNode.size = CGSize(width: 296, height: 80)
            croakNode.position = CGPoint(x: frame.midX, y: frame.midY - frame.size.height * 0.22)
        } else {
            croakNode.size = CGSize(width: 427, height: 116)
            croakNode.position = CGPoint(x: frame.midX, y: frame.midY - frame.size.height * 0.35)
        }
        
        croakNode.zPosition = 1
        addChild(croakNode)
    }

    func setupLoadingAnimation() {
        var animationFrames: [SKTexture] = []
        for i in 0...11 {
            let textureName = "loadingFrog\(i)"
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .nearest
            animationFrames.append(texture)
        }
        
        let frogNode = SKSpriteNode(texture: animationFrames[0])
        if DeviceHelper.isIPhone {
            frogNode.size = CGSize(width: 384, height: 384)
        } else {
            frogNode.size = CGSize(width: 555, height: 555)
        }
        frogNode.position = CGPoint(x: frame.midX, y: frame.midY + frame.size.height * 0.07)

        frogNode.zPosition = 0
        addChild(frogNode)
        
        let animateAction = SKAction.animate(with: animationFrames, timePerFrame: 0.1)
        frogNode.run(SKAction.repeatForever(animateAction))
    }
    
    func startMinimumTimeTimer() {
        let waitAction = SKAction.wait(forDuration: 6.0)
        let finishAction = SKAction.run {
            self.hasMinimumTimePassed = true
            self.tryProceedToMenu()
        }
        self.run(SKAction.sequence([waitAction, finishAction]))
    }

    func authenticateAndProceed() {
        guard let vc = gameViewController else {
            print("GameViewController não encontrado. Abortando autenticação.")
            self.isGameCenterReady = true
            return
        }
        GameCenterHelper.shared.authenticatePlayer(presentingVC: vc) {
            self.isGameCenterReady = true
            self.tryProceedToMenu()
        }
    }

    func tryProceedToMenu() {
        guard isGameCenterReady && hasMinimumTimePassed else {
            return
        }
        loadMenuScene()
    }

    func loadMenuScene() {
        guard view?.scene is LoadingScene else { return }

        let sceneName = DeviceHelper.isIPhone ? "MenuScene_iphone" : "MenuScene"
        if let menuScene = SKScene(fileNamed: sceneName) {
            menuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(menuScene, transition: transition)
        }
    }
}
