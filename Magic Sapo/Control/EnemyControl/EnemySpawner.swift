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
    private let enemyControl: EnemyControl
    
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
    
    init(scene: SKScene) {
        self.scene = scene
        self.enemyControl = EnemyControl() // Cria sua própria instância do controlador.
    }
    
    // MARK: - Controle do Spawning
    
    /// Inicia a criação contínua de inimigos.
    /// Inicia a criação contínua de inimigos.
    func startSpawningEnemies() {
        // Garante que apenas um timer exista por vez.
        // Se já houver um timer rodando, esta função não faz nada.
        guard spawnTimer == nil else { return }
        
        print("Spawner iniciado.")
        
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
    
    /// Repassa a chamada de atualização de velocidade para o controlador de inimigos.
    public func updateEnemySpeed(basedOn score: Int) {
        enemyControl.updateSpeed(basedOn: score)
    }
    
    
    /// Delega a chamada para matar um inimigo para o `enemyControl`.
    /// A GameScene falará com este método, e ele repassará a ordem.
    public func killEnemy(withGesture gesture: String) -> (points: Int, coins: Int)? {
        
        guard let scene = self.scene else { return nil }
        // Chama a função em EnemyControl e retorna diretamente o que ela devolver.
        return enemyControl.killEnemy(withGesture: gesture, in: scene)
    }
    /// Método chamado pelo timer para criar um inimigo.
    /// Precisa ser @objc para ser "visto" pelo seletor do Timer.
    // Método chamado pelo timer para decidir qual inimigo criar.
    /// Método chamado pelo timer para decidir qual inimigo criar.
    @objc private func spawnEnemy() {
        // --- MUDANÇA PRINCIPAL ---
        // Agora, verificamos se a cena se conforma ao nosso novo protocolo.
        // Isso funciona tanto para GameScene quanto para ButtonScene.
        guard let scoreScene = self.scene as? ScoreHavingScene,
              let actualScene = self.scene else {
            print("[DEBUG] ERRO: A cena atual não tem um scoreComponent ou é nula. Parando o spawner.")
            stopSpawningEnemies()
            return
        }
        
        let currentScore = scoreScene.scoreComponent.scoreCount
        
        // --- MUDANÇA 2: Lógica de Escolha Refatorada ---
        var enemyToSpawn: Enemy.Type?

        // Condições para spawnar um Ladrão:
        // 1. A pontuação é >= 15
        // 2. A pontuação é um múltiplo de 10
        // 3. AINDA NÃO criamos um Ladrão para esta pontuação exata.
        if currentScore >= 15 && currentScore % 10 == 0 && currentScore != lastThiefSpawnScore {
            enemyToSpawn = Thief.self
            // Atualiza nossa "memória" para a pontuação atual.
            lastThiefSpawnScore = currentScore
            print("Um Ladrão foi escolhido para spawnar, com \(currentScore) pontos")
        } else {
            // Se não for para criar um Ladrão, crie um Guarda.
            enemyToSpawn = Guards.self
        }
        
        // Cria o inimigo que foi escolhido.
        if let enemyType = enemyToSpawn {
            self.enemyControl.createEnemy(ofType: enemyType, in: actualScene)
        }
    }
    
    func spawnOnboardingEnemy(withGesture gesture: String, completion: @escaping (SKNode) -> Void) {
        guard let scene = self.scene else { return }
        
        // Usa o sistema existente para calcular posições
        let startPosition: CGPoint
        let middlePosition: CGPoint
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let halfWidth = scene.size.width / 2
            let halfHeight = scene.size.height / 2
            
            startPosition = CGPoint(x: 0, y: halfHeight + 50)
            middlePosition = CGPoint(x: 0, y: 0) // Centro da tela
        } else {
            // Para iPhone, usa sistema de coordenadas da view (igual ao createEnemy normal)
            guard let view = scene.view else { return }
            
            let topPointInView = CGPoint(x: view.bounds.midX, y: -100)
            startPosition = scene.convertPoint(fromView: topPointInView)
            
            let middlePointInView = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            middlePosition = scene.convertPoint(fromView: middlePointInView)
        }
        
        // USA O NOVO MÉTODO específico para onboarding
        guard let enemy = Guards.createForOnboarding(at: startPosition, withGesture: gesture) else {
            print("Erro ao criar inimigo de onboarding")
            return
        }
        
        // Adiciona à lista de inimigos ativos e à cena
        enemyControl.activeEnemies.append(enemy)
        scene.addChild(enemy)
        
        // Move até o meio da tela e para
        let moveToMiddle = SKAction.move(to: middlePosition, duration: 2.0)
        let stopAction = SKAction.run {
            enemy.removeAllActions()
            completion(enemy) // Chama o callback quando chegar no meio
        }
        
        let sequence = SKAction.sequence([moveToMiddle, stopAction])
        enemy.run(sequence)
    }

}
    
