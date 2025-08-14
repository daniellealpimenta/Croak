//
//  GameViewController.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Recebendo o aviso que o jogo vai ficar inativo
        NotificationCenter.default.addObserver(self, selector: #selector(PauseGame), name: NSNotification.Name("AppWillResignActive"), object: nil)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    // O erro era a falta do @objc (pesquisar dps)
    @objc func PauseGame() {
        print("Pausando o jogo")
        
        super.viewDidLoad()
        
        // MARK: as! -> Faz um cast formado para o SKView que pode ser vazio
        if let view = self.view as! SKView? {
            
            // So vou deixar ele pausado caso esteja na GameScene, a MenuScene vai ficar normal
            if let gameScene = view.scene as? GameScene {

                if let pauseScene = SKScene(fileNamed: "PauseScene") {
                    pauseScene.scaleMode = .aspectFill
                    
                    
                    // SO uma transicao
                    let transicao = SKTransition.fade(withDuration: 0.5)
                    view.presentScene(pauseScene, transition: transicao)
                }
                
            }
            
        }
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
