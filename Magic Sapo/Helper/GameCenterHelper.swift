//
//  GameCenterHelper.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 10/09/25.
//

import GameKit

final class GameCenterHelper: NSObject, GKGameCenterControllerDelegate {
    
    static let shared = GameCenterHelper()
    
    private var localPlayer: GKLocalPlayer {
        return GKLocalPlayer.local
    }
    
    public var isEnabled: Bool {
        return localPlayer.isAuthenticated
    }
    
    private var authenticationCompletion: (() -> Void)?
    
    private override init() {}
    
    func authenticatePlayer(presentingVC: UIViewController, completion: @escaping () -> Void) {
        self.authenticationCompletion = completion
        
        localPlayer.authenticateHandler = { gcAuthVC, error in
            if let viewControllerToPresent = gcAuthVC {
                if let gameCenterAuthVC = viewControllerToPresent as? GKGameCenterViewController {
                    gameCenterAuthVC.gameCenterDelegate = self
                }
                
                presentingVC.present(viewControllerToPresent, animated: true, completion: nil)
                return
            }
            
            DispatchQueue.main.async {
                self.authenticationCompletion?()
                self.authenticationCompletion = nil
            }
            
            if let error = error {
                print("Error authenticating player: \(error.localizedDescription)")
            } else if self.localPlayer.isAuthenticated {
                print("Player authenticated successfully!")
            } else {
                print("Player not authenticated.")
            }
        }
    }
    
    func submitScore(_ score: Int, to leaderboardID: String) {
        guard isEnabled else {
            print("Game Center not enabled. Cannot submit score.")
            return
        }
        
        GKLeaderboard.submitScore(score, context: 0, player: localPlayer, leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error submitting score: \(error.localizedDescription)")
            } else {
                print("Score submitted successfully! \(score)")
            }
        }
    }

    func showLeaderboard(presentingVC: UIViewController) {
        guard isEnabled else {
            print("Game Center not enabled. Cannot show leaderboard.")
            return
        }
        
        let gameCenterVC = GKGameCenterViewController(state: .leaderboards)
        // O helper também se torna o delegate aqui, para consistência
        gameCenterVC.gameCenterDelegate = self
        presentingVC.present(gameCenterVC, animated: true)
    }
    
    func fetchLeaderboardEntries(completion: @escaping (Result<[GKLeaderboard.Entry], Error>) -> Void) {
        let leaderboardID = "ranking_global"

        guard isEnabled else {
            let error = NSError(domain: "GameCenterError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Game Center not enabled."])
            completion(.failure(error))
            return
        }

        Task {
            do {
                let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
                
                guard let leaderboard = leaderboards.first(where: { $0.baseLeaderboardID == leaderboardID }) else {
                    let error = NSError(domain: "GameCenterError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Leaderboard not found."])
                    completion(.failure(error))
                    return
                }

                // A variável 'entries' aqui é a tupla de 3 partes.
                let entries = try await leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(location: 1, length: 100))
                
                // --- CORREÇÃO FINAL AQUI ---
                // Acessamos o SEGUNDO item da tupla (a lista de pontuações) com o índice .1
                completion(.success(entries.1))
                
            } catch {
                print("Erro ao buscar o placar do Game Center: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // Este método é chamado quando qualquer tela do Game Center (login, placar) é fechada.
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true) {
            // Executa a tarefa de conclusão que estava guardada
            DispatchQueue.main.async {
                self.authenticationCompletion?()
                self.authenticationCompletion = nil // Limpa a tarefa
            }
        }
    }
}
