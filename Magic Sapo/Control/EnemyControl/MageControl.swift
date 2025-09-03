//
//  MageControl.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 28/08/25.
//

import SpriteKit

class MageControl {
    
    /// O estado interno da batalha do chefe.
    private enum BossState {
        case waitingForFieldClear
        case entering
        case spawningWave
        case waitingForWave
        case waveDefeated
        case showingGesture
        case retreating
    }
    
    // --- MUDANÇA: A propriedade `scene` agora aceita o protocolo ---
    private weak var scene: BossFightScene?
    
    private weak var enemySpawner: EnemySpawner?
    
    private let mageStunDuration: TimeInterval = 1.5
    
    private var mageNode: SKSpriteNode?
    private var spawnedGuards: [SKNode] = []
    private var currentState: BossState = .waitingForFieldClear

    // O inicializador também foi atualizado para aceitar o tipo do protocolo.
    init(scene: BossFightScene, spawner: EnemySpawner) {
        self.scene = scene
        self.enemySpawner = spawner
    }
    
    /// Inicia a sequência da batalha.
    func startBossEncounter() {
            guard let scene = self.scene, let spawner = self.enemySpawner else { return }
            
            print("Iniciando encontro com o chefe. Parando spawn de inimigos normais.")
            spawner.stopSpawningEnemies()
            
            let waitAction = SKAction.wait(forDuration: 0.5)
            let checkAction = SKAction.run { [weak self] in
                // Se não houver mais inimigos normais, o chefe pode aparecer.
                if !spawner.hasActiveEnemies {
                    print("Campo limpo! O chefe vai aparecer.")
                    self?.scene?.removeAction(forKey: "waitForClearField")
                    self?.beginMageAppearance()
                } else {
                    print("Aguardando inimigos normais serem derrotados...")
                }
            }
            
            let sequence = SKAction.sequence([waitAction, checkAction])
            scene.run(SKAction.repeatForever(sequence), withKey: "waitForClearField")
        }
    
    private func beginMageAppearance() {
            guard let scene = self.scene else { return }
            
            // Avisa à cena que a batalha começou de verdade.
            scene.enterBossFightState()
            self.currentState = .entering
            
            // --- AJUSTES DE POSICIONAMENTO ---
            let finalYPosition = DeviceHelper.isIPhone ? scene.size.height / 2 - 120 : scene.size.height / 2 - 150
            // ---------------------------------
            
            let startPosition = CGPoint(x: 0, y: scene.size.height / 2 + 100)
            let finalPosition = CGPoint(x: 0, y: finalYPosition) // <-- MUDANÇA AQUI
            
            self.mageNode = Mage.create(at: startPosition)
            scene.addChild(self.mageNode!)
            
            let moveAction = SKAction.move(to: finalPosition, duration: 1.5)
            mageNode?.run(moveAction, completion: {
                self.transition(to: .spawningWave)
            })
        }
    
    private func stopMageMovement() {
            print("Pausando movimento do Mago.")
            mageNode?.removeAction(forKey: "mageMovement")
        }
    
    private func startMageMovement() {
        guard let mage = mageNode, let scene = self.scene else { return }
        if mage.action(forKey: "mageMovement") != nil {
            return
        }
        
        let endPosition = CGPoint(x: 0, y: -scene.size.height / 2 - 150)
        let moveAction = SKAction.move(to: endPosition, duration: 11.0) // Duração maior = mais lento
        mage.run(moveAction, withKey: "mageMovement")
    }
    
    /// Gerencia a entrada do jogador.
    func handlePlayer(gesture: String) {
        if currentState == .showingGesture {
            handleMageHit(gesture: gesture)
        }
        // O jogador só pode interagir com os guardas se estiver esperando por eles.
        else if currentState == .waitingForWave {
            handleGuardKill(gesture: gesture)
        }
    }
    
    /// Lida com a tentativa de matar um guarda.
    private func handleGuardKill(gesture: String) {
        var guardsToRemove: [SKNode] = []
        
        guard let scene = self.scene else { return }
        
        // --- AJUSTES DE POSICIONAMENTO ---
        let killZoneTopY: CGFloat = DeviceHelper.isIPhone ? scene.size.height / 2 - 100 : scene.size.height / 2 - 125
        let killZoneBottomY: CGFloat = DeviceHelper.isIPhone ? -scene.size.height / 2 + 180 : -scene.size.height / 2 + 215
        // ---------------------------------
        
        // --- MUDANÇA: Itera por todos os guardas para encontrar todas as correspondências ---
        for guardNode in spawnedGuards {
            guard guardNode.position.y < killZoneTopY && guardNode.position.y > killZoneBottomY else {
                continue
            }
            
            if guardNode.childNode(withName: gesture) != nil {
                guardsToRemove.append(guardNode)
            }
        }
        
        // Se nenhum guarda foi encontrado, não faz nada.
        if guardsToRemove.isEmpty { return }

        // Remove todos os guardas encontrados
        for guardNode in guardsToRemove {
            spawnedGuards.removeAll { $0 === guardNode }
            
            guardNode.removeAllActions()
            
            let animateFrames = SKAction.animate(with: Guards.deathAnimation, timePerFrame: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            
            let combinedDeathAnimation = SKAction.group([animateFrames, fadeOut])
                        
            guardNode.run(SKAction.sequence([combinedDeathAnimation, SKAction.removeFromParent()]))
            
        }
        
        // Se não houver mais guardas, avança para o próximo estado
        if spawnedGuards.isEmpty {
            transition(to: .waveDefeated)
        }
    }
    
    /// Lida com a tentativa de acertar o Mago.
    private func handleMageHit(gesture: String) {
        guard let mage = self.mageNode, let scene = self.scene else { return }
        
        let killZoneTopY: CGFloat = DeviceHelper.isIPhone ? scene.size.height / 2 - 100 : scene.size.height / 2 - 125
        let killZoneBottomY: CGFloat = DeviceHelper.isIPhone ? -scene.size.height / 2 + 180 : -scene.size.height / 2 + 215
        
        guard mage.position.y < killZoneTopY && mage.position.y > killZoneBottomY else {
            return // Se estiver fora da zona, a função para aqui.
        }
        
        if let gestureNode = mage.childNode(withName: gesture) {
            gestureNode.removeFromParent()
            
            // --- MUDANÇA: Adiciona recompensa por acertar o Mago ---
            stopMageMovement()
            
            if var health = mage.userData?["health"] as? Int {
                health -= 1
                mage.userData?["health"] = health
                
                if health > 0 {
                    // Se ainda tem vida, invoca a próxima onda.
                    let waitAction = SKAction.wait(forDuration: mageStunDuration)
                    let startNextWaveAction = SKAction.run { [weak self] in
                        self?.transition(to: .spawningWave)
                    }
                    
                    // A cena executa a ação para garantir que funcione mesmo que o mago seja removido.
                    scene.run(SKAction.sequence([waitAction, startNextWaveAction]))
                } else {
                    // Se a vida acabou, o Mago é derrotado.
                    scene.scoreComponent.addScore(point: Mage.pointValue)
                    scene.coinsComponent.addCoins(coins: Mage.coinValue)
                    transition(to: .retreating)
                }
            }
        }
    }
    
    /// Invoca uma onda de 4 guardas.
    private func spawnWave() {
        guard let scene = self.scene, let mage = self.mageNode else { return }
        
        // --- CORREÇÃO 1: Garante gestos únicos para cada guarda ---
        // 1. Pega os gestos disponíveis e os embaralha.
        var waveGestures = Gestures.availableGestures.shuffled()
        
        let xStartOffset: CGFloat = DeviceHelper.isIPhone ? -110 : -150
        let xSpacing: CGFloat = DeviceHelper.isIPhone ? 75 : 100
        
        for i in 0..<4 {
            // 2. Tira um gesto da lista para usar. O 'popLast' garante que não será repetido.
            guard let gestureForGuard = waveGestures.popLast() else { continue }
            
            let xOffSet = xStartOffset + (CGFloat(i) * xSpacing) // <-- MUDANÇA AQUI
            let startPosition = CGPoint(x: mage.position.x + xOffSet, y: mage.position.y)
            
            // 3. Cria o guarda passando o gesto específico que ele deve ter.
            if let guardNode = Guards.createdByMage(at: startPosition, withGesture: gestureForGuard) {
                spawnedGuards.append(guardNode)
                scene.addChild(guardNode)
                
                let endPosition = CGPoint(x: 0, y: -scene.size.height / 2 - 100)
                let moveAction = SKAction.move(to: endPosition, duration: 7.0)
                
                let removeAction = SKAction.run { [weak self] in
                    self?.spawnedGuards.removeAll { $0 === guardNode }
                    guardNode.removeFromParent()
                }
                
                guardNode.run(SKAction.sequence([moveAction, removeAction]))
            }
        }
    }
    
    /// Mostra o próximo gesto que o Mago exige.
    private func showMageGesture() {
        guard let mage = self.mageNode else { return }
        
        let gestureName = Gestures.availableGestures.randomElement()!
        
        // --- AJUSTES DE TAMANHO E POSIÇÃO ---
        let gestureSize = DeviceHelper.isIPhone ? CGSize(width: 50, height: 50) : CGSize(width: 70, height: 70)
        let gestureYPosition = DeviceHelper.isIPhone ? CGFloat(90) : CGFloat(120)
        // ---------------------------------
        
        let gestureSprite = SKSpriteNode(imageNamed: gestureName)
        gestureSprite.size = gestureSize // <-- MUDANÇA AQUI
        gestureSprite.position = CGPoint(x: 0, y: gestureYPosition) // <-- MUDANÇA AQUI
        gestureSprite.name = gestureName
        
        gestureSprite.alpha = 0
        mage.addChild(gestureSprite)
        
        // --- MUDANÇA CHAVE 2 ---
        // A ação de se tornar vulnerável agora acontece DEPOIS do fade-in.
        let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
        let makeVulnerableAction = SKAction.run { [weak self] in
            self?.transition(to: .showingGesture)
        }
        
        gestureSprite.run(SKAction.sequence([fadeInAction, makeVulnerableAction]))
    }
    
    /// A máquina de estados central da batalha.
    private func transition(to newState: BossState) {
        self.currentState = newState
        
        switch currentState {
        case .spawningWave:
            spawnWave()
                        
            // Cria um atraso antes de o Mago começar a se mover.
            let waitAction = SKAction.wait(forDuration: 1.2)
            let startMovingAction = SKAction.run { [weak self] in
                self?.startMageMovement()
            }
            mageNode?.run(SKAction.sequence([waitAction, startMovingAction]))
            
            // Define o estado de espera APÓS iniciar a ação.
            self.currentState = .waitingForWave
            
        case .waveDefeated:
            // --- MUDANÇA CHAVE 1 ---
            // Agora, este estado apenas inicia o processo de mostrar o gesto.
            // Ele não faz a transição para .showingGesture diretamente.
            guard let scene = self.scene else { return }
            let wait = SKAction.wait(forDuration: 0.25) // Aumentei um pouco o tempo para ficar mais claro
            let prepareGesture = SKAction.run { [weak self] in
                self?.showMageGesture()
            }
            scene.run(SKAction.sequence([wait, prepareGesture]))
            
        case .showingGesture:
            // --- MUDANÇA CHAVE 3 ---
            // Este estado agora é "passivo". Ele só significa que o chefe está vulnerável.
            // A ação de mostrar o gesto já foi iniciada.
            break
            
        case .retreating:
            mageNode?.removeAllActions()
            let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 400), duration: 1.5)
            mageNode?.run(moveAction, completion: {
                self.mageNode?.removeFromParent()
                self.scene?.bossFightDidEnd()
            })
            
        default:
            break
        }
    }
}
