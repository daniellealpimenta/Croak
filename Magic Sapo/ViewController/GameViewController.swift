//
//  GameViewController.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 09/08/25.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Recebendo o aviso que o jogo vai ficar inativo
        NotificationCenter.default.addObserver(self, selector: #selector(PauseGame), name: NSNotification.Name("AppWillResignActive"), object: nil)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                
                // CONFIGURAÇÃO ADAPTATIVA DO SCALE MODE
                if DeviceHelper.isIPhone {
                    scene.scaleMode = .aspectFill  // Melhor para iPhone
                } else {
                    scene.scaleMode = .aspectFit   // Melhor para iPad
                }
                
                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    // MARK: - Método para lidar com mudanças de orientação
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            // Código executado durante a transição
        }, completion: { _ in
            // Código executado após a transição ser completada
            self.updateCameraOrientation()
        })
    }
    
    private func updateCameraOrientation() {
        // Acessa a cena atual e atualiza a orientação da câmera se necessário
        if let view = self.view as? SKView,
           let scene = view.scene {
            
            // Se a cena atual tem um gesture detection manager, atualize sua orientação
            // Você pode implementar isso de diferentes formas dependendo de como sua arquitetura está estruturada
            
            // Opção 1: Se o GestureDetectionManager está na GameScene
            if let gameScene = scene as? GameScene {
                gameScene.gestureManager?.updateOrientation()
            }
            
            // Opção 2: Se você tem uma referência direta no GameViewController
            // gestureDetectionManager?.updateOrientation()
            
            // Opção 3: Usando NotificationCenter para comunicar com as cenas
            NotificationCenter.default.post(name: NSNotification.Name("OrientationDidChange"), object: nil)
        }
    }
    
    // O erro era a falta do @objc (pesquisar dps)
    @objc func PauseGame() {
        print("Pausando o jogo")
        
        // MARK: as! -> Faz um cast formado para o SKView que pode ser vazio
        if let view = self.view as! SKView? {
            
            if let gameScene = view.scene as? GameScene {

                // Forcando um cast para a PauseScene
                if let pauseScene = SKScene(fileNamed: "PauseScene") as? PauseScene {
                    
                    pauseScene.setGameScene(scene: gameScene)
                    
                    pauseScene.scaleMode = .aspectFill
                    let transicao = SKTransition.fade(withDuration: 0.5)
                    view.presentScene(pauseScene, transition: transicao)
                }
            }
            
        }
    }

//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Adapta as orientações suportadas baseado no dispositivo
        if DeviceHelper.isIPhone {
            return .portrait  // iPhone 
        } else {
            return .landscapeRight      // iPad
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
