////
//// GameScene.swift
//// Magic Sapo
////
//// Created by Pedro Santos on 09/08/25.
////
//import SpriteKit
//import GameplayKit
//
//class GameScene: SKScene {
//    
//    var timerComponent: TimerComponent!
//    var backgroundComponent: BackgroundComponent!
//    var enemySpawner: EnemySpawner!
//    
//    override func didMove(to view: SKView) {
//        
//        if backgroundComponent == nil {
//            backgroundComponent = BackgroundComponent(parent: self)
//        }
//        backgroundComponent.setupAnimatedBackground()
//        
//        if timerComponent == nil {
//            timerComponent = TimerComponent(parent: self)
//        }
//        timerComponent.start()
//    
//        self.enemySpawner = EnemySpawner(scene: self)
//        self.enemySpawner.startSpawningEnemies()
//    }
//    
//    override func willMove(from view: SKView) {
//        timerComponent.stop()
//        enemySpawner.stopSpawningEnemies()
//    }
//    
//    func playerDidMake(gesture: String) {
//        enemySpawner.killEnemy(withGesture: gesture)
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let touchedNode = atPoint(location)
//        
//        if touchedNode.name == "PauseButton" {
//            print("Botão Pausar foi tocado!")
//            
//            guard let pauseScene = SKScene(fileNamed: "PauseScene") as? PauseScene else {
//                print("ERRO: Não foi possível carregar a PauseScene.")
//                return
//            }
//            
//            pauseScene.setGameScene(scene: self)
//            pauseScene.scaleMode = .aspectFill
//            let transition = SKTransition.fade(withDuration: 0.5)
//            self.view?.presentScene(pauseScene, transition: transition)
//        }
//        
//    }
//}

//
// GameScene.swift
// Magic Sapo
//
// Created by Pedro Santos on 09/08/25.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var scoreComponent: ScoreComponent!
    var backgroundComponent: BackgroundComponent!
    var enemySpawner: EnemySpawner!
    
    override func didMove(to view: SKView) {
        
        if backgroundComponent == nil {
            backgroundComponent = BackgroundComponent(parent: self)
        }
        backgroundComponent.setupAnimatedBackground()
        
        if scoreComponent == nil {
            scoreComponent = ScoreComponent(parent: self)
        }
    
        self.enemySpawner = EnemySpawner(scene: self)
        self.enemySpawner.startSpawningEnemies()
        

        let rockButton = SKSpriteNode(imageNamed: "Rock")
        rockButton.name = "rockButton"
        rockButton.size = CGSize(width: 80, height: 80)
 
        rockButton.position = CGPoint(x: -100, y: -self.size.height/2 + 100)
        
        self.addChild(rockButton)
        
        let twoButton = SKSpriteNode(imageNamed: "Two")
        twoButton.name = "twoButton"
        twoButton.size = CGSize(width: 80, height: 80)

        twoButton.position = CGPoint(x: 100, y: -self.size.height/2 + 100)

        self.addChild(twoButton)
    }
    
    override func willMove(from view: SKView) {
        enemySpawner.stopSpawningEnemies()
    }
    
//    func playerDidMake(gesture: String) {
//        enemySpawner.killEnemy(withGesture: gesture, enemy: )
//    }
    
    func playerDidMake(gesture: String) {
        if let pointsGained = enemySpawner.killEnemy(withGesture: gesture) {
            scoreComponent.addScore(point: pointsGained)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "PauseButton" {
            print("Botão Pausar foi tocado!")
            
            guard let pauseScene = SKScene(fileNamed: "PauseScene") as? PauseScene else {
                print("ERRO: Não foi possível carregar a PauseScene.")
                return
            }
            
            pauseScene.setGameScene(scene: self)
            pauseScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(pauseScene, transition: transition)
        }
        
        if touchedNode.name == "rockButton" {
            playerDidMake(gesture: "Rock")
        }
        
        if touchedNode.name == "twoButton" {
            playerDidMake(gesture: "Two")
        }
    }
}
