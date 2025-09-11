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
import GameKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let view = self.view as! SKView? {
            
            let loadingScene = LoadingScene(size: view.bounds.size)
            loadingScene.scaleMode = .aspectFill
            
            loadingScene.gameViewController = self
            
            view.presentScene(loadingScene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Adapta as orientações suportadas baseado no dispositivo
        if DeviceHelper.isIPhone {
            return .portrait  // iPhone 
        } else {
            return .landscapeRight  // iPad
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
