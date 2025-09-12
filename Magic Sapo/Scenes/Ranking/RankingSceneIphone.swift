//
//  RankingSceneIphone.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 11/09/25.
//

import SpriteKit
import GameKit

class RankingSceneIphone: SKScene {

    private var isTransitioning = false

    override func didMove(to view: SKView) {
        fetchAndDisplayLeaderboard()
    }

    func fetchAndDisplayLeaderboard() {
        // --- DEBUG A ---
        print("🕵️‍♂️ DEBUG A: RankingScene - Iniciando a busca pelo placar.")
        
        let loadingLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
        loadingLabel.text = "Carregando Ranking..."
        loadingLabel.fontSize = 28
        loadingLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        loadingLabel.name = "loadingLabel"
        addChild(loadingLabel)

        GameCenterHelper.shared.fetchLeaderboardEntries { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.childNode(withName: "loadingLabel")?.removeFromParent()

                // --- DEBUG C ---
                print("🚦 DEBUG C: RankingScene - Recebeu uma resposta do GameCenterHelper.")

                switch result {
                case .success(let entries):
                    // --- DEBUG D ---
                    print("✅ DEBUG D: RankingScene - Sucesso! Número de entradas recebidas: \(entries.count)")
                    self.display(entries: entries)
                
                case .failure(let error):
                    // --- DEBUG D (Falha) ---
                    print("❌ DEBUG D: RankingScene - Falha! Erro: \(error.localizedDescription)")
                    self.displayError(message: "Falha ao carregar.\nVerifique sua conexão.")
                }
            }
        }
    }

    func display(entries: [GKLeaderboard.Entry]) {
        // --- DEBUG E ---
        print("🎨 DEBUG E: RankingScene - Iniciando a exibição de \(entries.count) entradas.")
        
        if entries.isEmpty {
            displayError(message: "Nenhuma pontuação.")
            return
        }
        
        var yPosition = self.frame.size.height * 0.35
        let rankX = self.frame.size.width * 0.18
        let nameX = self.frame.size.width * 0.30
        let scoreX = self.frame.size.width * 0.85

        for entry in entries {
            // --- DEBUG F ---
            print("  - Exibindo: Rank \(entry.rank), Jogador '\(entry.player.displayName)', Pontuação \(entry.formattedScore)")
            
            let rankLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            rankLabel.text = "\(entry.rank)."
            rankLabel.horizontalAlignmentMode = .left
            rankLabel.fontSize = 24
            rankLabel.position = CGPoint(x: rankX, y: yPosition)

            let nameLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            nameLabel.text = entry.player.displayName
            nameLabel.horizontalAlignmentMode = .left
            nameLabel.fontSize = 24
            nameLabel.position = CGPoint(x: nameX, y: yPosition)

            let scoreLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            scoreLabel.text = entry.formattedScore
            scoreLabel.horizontalAlignmentMode = .right
            scoreLabel.fontSize = 24
            scoreLabel.position = CGPoint(x: scoreX, y: yPosition)

            addChild(rankLabel)
            addChild(nameLabel)
            addChild(scoreLabel)
            
            yPosition -= 45
        }
    }

    func displayError(message: String) {
        let errorLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
        errorLabel.text = message
        errorLabel.fontSize = 28
        errorLabel.numberOfLines = 2
        errorLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(errorLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning, let touch = touches.first else { return }
        let location = touch.location(in: self)
        var node = self.atPoint(location)
        while node.name != "close_button" && node.parent != nil {
            node = node.parent!
        }
        if node.name == "close_button" {
            exitToMenu()
        }
    }

    private func exitToMenu() {
        guard !isTransitioning else { return }
        isTransitioning = true
        let sceneName = "MenuScene_iphone"
        if let menuScene = SKScene(fileNamed: sceneName) {
            menuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.5)
            view?.presentScene(menuScene, transition: transition)
        }
    }
}

