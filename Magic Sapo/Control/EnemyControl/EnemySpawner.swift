//
//  EnemySpawner.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//
import Foundation
import SpriteKit

/// Responsável por controlar QUANDO e QUAL inimigo deve ser criado na cena.
/// Ele gerencia o timing e a seleção dos inimigos.
class EnemySpawner {
    
    // MARK: - Propriedades
    
    /// Lista de todos os tipos de inimigos que podem ser criados. Para adicionar um novo, basta colocar seu tipo aqui.
    private let availableEnemies: [Enemy.Type] = [Guards.self, Thief.self]
    
    /// Instância do controlador que sabe COMO criar e destruir inimigos. O Spawner delega o trabalho para ele.
    let enemyControl: EnemyControl
    
    private weak var parentNode: SKNode?
    
    private var scoreAtLastThiefSpawn = 0
    
    /// Referência **fraca** (weak) à cena para evitar "ciclos de retenção" (memory leaks).
    /// A cena "possui" o spawner, então o spawner não pode "possuir" a cena de volta com força total.
    weak var scene: SKScene?
    
    /// O timer que dispara a criação de inimigos em intervalos regulares.
    var spawnTimer: Timer?
    
    private var lastThiefSpawnScore = -1
    
    public var hasActiveEnemies: Bool {
        return !enemyControl.activeEnemies.isEmpty
    }
    
    // MARK: - Inicialização
    
    init(parentNode: SKNode, scene: SKScene) {
        self.parentNode = parentNode
        self.scene = scene
        self.enemyControl = EnemyControl()
    }
    
    // MARK: - Controle do Spawning
    
    /// Inicia a criação contínua de inimigos.
    /// Inicia a criação contínua de inimigos.
    func startSpawningEnemies() {
        // Garante que apenas um timer exista por vez.
        // Se já houver um timer rodando, esta função não faz nada.
        guard spawnTimer == nil else { return }
        
        // Cria um timer que chama a função 'spawnEnemy' a cada 3 segundos.
        // Usar target/selector deixa o código de start/stop mais limpo.
        spawnTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(spawnEnemy),
            userInfo: nil,
            repeats: true
        )
    }
    /// Para o timer e interrompe a criação de novos inimigos.
    func stopSpawningEnemies() {
        
        // MARK: Funcao importante para controlar os Spawns (invalidate)
        spawnTimer?.invalidate() // Invalida o timer.
        spawnTimer = nil // Limpa a referência ao timer.
    }
    
    // MARK: - Ações Públicas
    
    /// Delega a chamada para matar um inimigo para o `enemyControl`.
    /// A GameScene falará com este método, e ele repassará a ordem.
    public func killEnemy(withGesture gesture: String) -> (points: Int, coins: Int)? {
        
        guard let scene = self.scene else { return nil }
        // Chama a função em EnemyControl e retorna diretamente o que ela devolver.
        return enemyControl.killEnemy(withGesture: gesture, in: scene)
    }

    @objc private func spawnEnemy() {

        guard let scoreScene = self.scene as? ScoreHavingScene,
              let actualScene = self.scene,
              let parent = self.parentNode else {
            stopSpawningEnemies()
            return
        }
        
        let currentScore = scoreScene.scoreComponent.scoreCount
        
        let scoreSinceLastThief = currentScore - scoreAtLastThiefSpawn
        
        var enemyToSpawn: Enemy.Type?

        if currentScore >= 15 && scoreSinceLastThief >= 10 {
            enemyToSpawn = Thief.self

            scoreAtLastThiefSpawn = currentScore

        } else {
            enemyToSpawn = Guards.self
        }
        
        if let enemyType = enemyToSpawn {
            self.enemyControl.createEnemy(ofType: enemyType, on: parent, in: actualScene)
        }
    }
    
    func spawnOnboardingGuard(withGesture gesture: String, completion: @escaping (SKNode) -> Void) {
        guard let scene = self.scene else { return }
            
        let startPosition: CGPoint
        let middlePosition: CGPoint
                    
        // Usando DeviceHelper para consistência com o resto do código
        if DeviceHelper.isIPad {
            let halfHeight = scene.size.height / 2
                
            startPosition = CGPoint(x: 0, y: halfHeight + 50)
            middlePosition = CGPoint(x: 0, y: 50) // Posição original para iPad
        } else {
            // --- LÓGICA PARA IPHONE ---
            guard let view = scene.view else { return }
                
            let topPointInView = CGPoint(x: view.bounds.midX, y: -100)
            startPosition = scene.convertPoint(fromView: topPointInView)
                
            // Isso fará o inimigo parar mais para cima.
            let middleY = view.bounds.height * 0.4
            let middlePointInView = CGPoint(x: view.bounds.midX, y: middleY)
            middlePosition = scene.convertPoint(fromView: middlePointInView)
        }
        
            
        guard let enemy = Guards.createForOnboarding(at: startPosition, withGesture: gesture) else {
            return
        }
            
        enemyControl.activeEnemies.append(enemy)
        scene.addChild(enemy)
            
        let moveToMiddle = SKAction.move(to: middlePosition, duration: 3.5)
        let stopAction = SKAction.run {
            enemy.removeAllActions()
            completion(enemy)
        }
            
        let sequence = SKAction.sequence([moveToMiddle, stopAction])
        enemy.run(sequence)
    }
    
    func spawnOnboardingThief(withGestures gestures: [String], completion: @escaping (SKNode) -> Void) {
        guard let scene = self.scene else { return }

        let startPosition: CGPoint
        let middlePosition: CGPoint
                    
        // Usando DeviceHelper para consistência
        if DeviceHelper.isIPad {
            startPosition = CGPoint(x: 0, y: scene.size.height / 2 + 50)
            middlePosition = CGPoint(x: 0, y: 50) // Posição original para iPad
        } else {
            // --- LÓGICA PARA IPHONE ---
            guard let view = scene.view else { return }
            let topPointInView = CGPoint(x: view.bounds.midX, y: -100)
            startPosition = scene.convertPoint(fromView: topPointInView)
                
            // AJUSTE AQUI: Repetimos a mesma lógica do Guarda para o Ladrão.
            let middleY = view.bounds.height * 0.4
            let middlePointInView = CGPoint(x: view.bounds.midX, y: middleY)
            middlePosition = scene.convertPoint(fromView: middlePointInView)
        }
        
        guard let enemy = Thief.createForOnboarding(at: startPosition, withGestures: gestures) else {
            return
        }

        enemyControl.activeEnemies.append(enemy)
        scene.addChild(enemy)

        let moveToMiddle = SKAction.move(to: middlePosition, duration: 2.0)
        let stopAction = SKAction.run {
            enemy.removeAllActions()
            completion(enemy)
        }
        let sequence = SKAction.sequence([moveToMiddle, stopAction])
        enemy.run(sequence)
    }


}
    
