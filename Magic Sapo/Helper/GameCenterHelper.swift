//
//  GameCenterHelper.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 10/09/25.
//

import GameKit

final class GameCenterHelper {
    
    static let shared = GameCenterHelper()
    
    private var localPlayer: GKLocalPlayer {
        return GKLocalPlayer.local
    }
    
    public var isEnabled: Bool {
        return localPlayer.isAuthenticated
    }
    
    private init() {}
    
 
    func authenticatePlayer(presentingVC: UIViewController) {
        localPlayer.authenticateHandler = { gcAuthVC, error in
            if let viewController = gcAuthVC {
                presentingVC.present(viewController, animated: true)
                return
            }
            
            if let error = error {
                print("Error authenticating player: \(error.localizedDescription)")
                return
            }
            
            if self.localPlayer.isAuthenticated {
                print("Player authenticated successfully!")
            } else {
                print("Player not authenticated.")
            }
        }
    }
    
    // 2. ENVIAR PONTUAÇÃO
    // Chame isso quando o jogo terminar ou quando o jogador atingir uma nova pontuação máxima.
    func submitScore(_ score: Int, to leaderboardID: String) {
        guard isEnabled else {
            print("Game Center not enabled. Cannot submit score.")
            return
        }
        
        GKLeaderboard.submitScore(score, context: 0, player: localPlayer, leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error submitting score: \(error.localizedDescription)")
            } else {
                print("Score of \(score) submitted to \(leaderboardID) successfully!")
            }
        }
    }

    // 3. MOSTRAR A INTERFACE DO GAME CENTER (PLACAR DE LÍDERES)
    // Chame isso quando o jogador tocar em um botão "Ranking" ou "Leaderboard".
    func showLeaderboard(presentingVC: UIViewController) {
        guard isEnabled else {
            print("Game Center not enabled. Cannot show leaderboard.")
            return
        }
        
        let gameCenterVC = GKGameCenterViewController(state: .leaderboards)
        gameCenterVC.gameCenterDelegate = presentingVC as? GKGameCenterControllerDelegate
        presentingVC.present(gameCenterVC, animated: true)
    }
}

// Extensão para que o GameViewController possa fechar a tela do Game Center
extension GameViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
