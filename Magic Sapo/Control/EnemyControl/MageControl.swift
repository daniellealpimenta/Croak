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
    
    private let mageStunDuration: TimeInterval = 2.0
    
    private var mageNode: SKSpriteNode?
    private var spawnedGuards: [SKNode] = []
    private var currentState: BossState = .waitingForFieldClear
    
    let mageSpeed: Double = DeviceHelper.isIPhone ? 9.0 : 10.0
    let guardSpeed: Double = DeviceHelper.isIPhone ? 5.0 : 6.0

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
            mageNode?.removeAction(forKey: "walkAnimation")
        }
    
    private func startMageMovement() {
        guard let mage = mageNode, let scene = self.scene else { return }
        if mage.action(forKey: "mageMovement") != nil {
            return
        }
        
        // ANIMAÇÃO: Escolhe a animação de andar correta baseada na vida do Mago.
        if let health = mage.userData?["health"] as? Int {
            let walkFrames = (health == 1) ? Mage.walkCrackedAnimation : Mage.walkAnimation
            let walkAnimation = SKAction.animate(with: walkFrames, timePerFrame: 0.2)
            mage.run(SKAction.repeatForever(walkAnimation), withKey: "walkAnimation")
        }
        
        let endPosition = CGPoint(x: 0, y: -scene.size.height / 2 - 150)
        let moveAction = SKAction.move(to: endPosition, duration: mageSpeed) // Duração maior = mais lento
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
        
        for guardNode in spawnedGuards {
            guard scene.killZoneRect.contains(guardNode.position) else {
                continue
            }
            
            if guardNode.childNode(withName: gesture) != nil {
                guardsToRemove.append(guardNode)
            }
        }
        
        if guardsToRemove.isEmpty { return }

        for guardNode in guardsToRemove {
            spawnedGuards.removeAll { $0 === guardNode }
            
            guardNode.removeAllActions()
            
            let animateFrames = SKAction.animate(with: Guards.deathAnimation, timePerFrame: 0.25)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            
            let combinedDeathAnimation = SKAction.group([animateFrames, fadeOut])
                        
            guardNode.run(SKAction.sequence([combinedDeathAnimation, SKAction.removeFromParent()]))
            
        }
        
        if spawnedGuards.isEmpty {
            transition(to: .waveDefeated)
        }
    }
    
    /// Lida com a tentativa de acertar o Mago.
    private func handleMageHit(gesture: String) {
        guard let mage = self.mageNode, let scene = self.scene else { return }
        
        guard scene.killZoneRect.contains(mage.position) else {
            return
        }
        
        if let gestureNode = mage.childNode(withName: gesture) {
            gestureNode.removeFromParent()
            
            stopMageMovement()
            
            if var health = mage.userData?["health"] as? Int {
                health -= 1
                mage.userData?["health"] = health
                
                if health > 0 {
                    let crackAnimation = SKAction.animate(with: Mage.shieldCrackAnimation, timePerFrame: 0.25)
                    let setIdleDamagedFrame = SKAction.run {
                        if let idleFrame = Mage.walkCrackedAnimation.first {
                            mage.texture = idleFrame
                        }
                    }
                    mage.run(SKAction.sequence([crackAnimation, setIdleDamagedFrame]))
                    
                    let waitAction = SKAction.wait(forDuration: mageStunDuration)
                    let startNextWaveAction = SKAction.run { [weak self] in self?.transition(to: .spawningWave) }
                    scene.run(SKAction.sequence([waitAction, startNextWaveAction]))
                } else {
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
        
        mage.removeAction(forKey: "walkAnimation")
        if let health = mage.userData?["health"] as? Int {
            mage.texture = (health == 1) ? Mage.invokingTextureCrack : Mage.invokingTexture
        }
        
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
                let moveAction = SKAction.move(to: endPosition, duration: guardSpeed)
                
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
            
            
            let breakShield = SKAction.animate(with: Mage.shieldBreakingAnimation, timePerFrame: 0.30)
            let turnAround = SKAction.animate(with: Mage.mageTurnAnimation, timePerFrame: 0.08)
            
            let moveOffscreen = SKAction.move(by: CGVector(dx: 0, dy: 800), duration: 1.5)
            let runAnimation = SKAction.animate(with: Mage.mageRanAnimation, timePerFrame: 0.25)
            
            let runningDuringEscape = SKAction.repeat(runAnimation, count: 2)
            let escapeGroup = SKAction.group([moveOffscreen, runningDuringEscape])
            
            let fullSequence = SKAction.sequence([breakShield, turnAround, escapeGroup])
            
            mageNode?.run(fullSequence, completion: {
                self.mageNode?.removeFromParent()
                self.scene?.bossFightDidEnd()
            })
            
        default:
            break
        }
    }
}
