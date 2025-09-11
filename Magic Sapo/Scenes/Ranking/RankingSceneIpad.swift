//
//  RankingSceneIpad.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 11/09/25.
//

import SpriteKit
import GameKit

class RankingSceneIpad: SKScene {

    private var isTransitioning = false

    override func didMove(to view: SKView) {
        setupBackButton()
        fetchAndDisplayLeaderboard()
    }

    func setupBackButton() {
        if let backButton = self.childNode(withName: "//BackButton") {
            // Lógica do botão tratada em touchesBegan
        }
    }

    func fetchAndDisplayLeaderboard() {
        // Mostra o feedback de carregamento
        let loadingLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
        loadingLabel.text = "Carregando Ranking..."
        loadingLabel.fontSize = 50 // Tamanho maior para iPad
        loadingLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        loadingLabel.name = "loadingLabel"
        addChild(loadingLabel)

        // Chama o Helper para buscar os dados
        GameCenterHelper.shared.fetchLeaderboardEntries { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.childNode(withName: "loadingLabel")?.removeFromParent()

                switch result {
                case .success(let entries):
                    self.display(entries: entries)
                case .failure(_):
                    self.displayError(message: "Falha ao carregar.\nVerifique sua conexão.")
                }
            }
        }
    }

    func display(entries: [GKLeaderboard.Entry]) {
        if entries.isEmpty {
            displayError(message: "Nenhuma pontuação.")
            return
        }

        // --- LAYOUT PARA IPAD ---
        // Posição Y inicial para a primeira linha do ranking
        var yPosition = self.frame.size.height * 0.30

        // Posições X fixas para cada coluna
        let rankX = self.frame.size.width * 0.20
        let nameX = self.frame.size.width * 0.28
        let scoreX = self.frame.size.width * 0.80

        for entry in entries {
            let rankLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            rankLabel.text = "\(entry.rank)."
            rankLabel.horizontalAlignmentMode = .left
            rankLabel.fontSize = 40 // Tamanho de fonte para iPad
            rankLabel.position = CGPoint(x: rankX, y: yPosition)

            let nameLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            nameLabel.text = entry.player.displayName
            nameLabel.horizontalAlignmentMode = .left
            nameLabel.fontSize = 40
            nameLabel.position = CGPoint(x: nameX, y: yPosition)

            let scoreLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
            scoreLabel.text = entry.formattedScore
            scoreLabel.horizontalAlignmentMode = .right
            scoreLabel.fontSize = 40
            scoreLabel.position = CGPoint(x: scoreX, y: yPosition)

            addChild(rankLabel)
            addChild(nameLabel)
            addChild(scoreLabel)

            // Espaçamento maior entre as linhas no iPad
            yPosition -= 65
        }
    }

    func displayError(message: String) {
        let errorLabel = SKLabelNode(fontNamed: "Ari-W9500Bold")
        errorLabel.text = message
        errorLabel.fontSize = 50
        errorLabel.numberOfLines = 2
        errorLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(errorLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning, let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        if touchedNode.name == "BackButton" {
            exitToMenu()
        }
    }

    private func exitToMenu() {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        let sceneName = "MenuScene" // A cena de menu do iPad
        if let menuScene = SKScene(fileNamed: sceneName) {
            menuScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(menuScene, transition: transition)
        }
    }
}
