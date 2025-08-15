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
    private let availableEnemies: [Enemy.Type] = [Guards.self]
    
    /// Instância do controlador que sabe COMO criar e destruir inimigos. O Spawner delega o trabalho para ele.
    private let enemyControl: EnemyControl
    
    /// Referência **fraca** (weak) à cena para evitar "ciclos de retenção" (memory leaks).
    /// A cena "possui" o spawner, então o spawner não pode "possuir" a cena de volta com força total.
    weak var scene: SKScene?
    
    /// O timer que dispara a criação de inimigos em intervalos regulares.
    var spawnTimer: Timer?
    
    // MARK: - Inicialização
    
    init(scene: SKScene) {
        self.scene = scene
        self.enemyControl = EnemyControl() // Cria sua própria instância do controlador.
    }

    // MARK: - Controle do Spawning
    
    /// Inicia a criação contínua de inimigos.
    func startSpawningEnemies() {
        
        // Cria um timer que se repete a cada 3 segundos.
        // [weak self] é crucial para evitar memory leak com o timer.
        // Vamo ter que mudar essa logica para cada inimigo se pa, pq ele ta spawnando inimigos a cada 3 segundos, mas pode ser que a gente precise criar um Timer aleatorio individual ou sei la
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            
            // Garante que 'self' (o spawner) e a 'scene' ainda existem.
            // Essa bomba nao funciona se nao tiver
            guard let self = self, let scene = self.scene else { return }
            
            // Escolhe um tipo de inimigo aleatoriamente da lista de disponíveis.
            if let randomEnemyType = self.availableEnemies.randomElement() {
                
                // Pede para o controlador criar o inimigo escolhido na cena.
                self.enemyControl.createEnemy(ofType: randomEnemyType, in: scene)
            }
        }
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
}

// Isso daqui eram as formas anteriores que eu tava fazendo isso

//    public func killEnemy(withGesture gesture: String) {
//        guard let scene = self.scene else { return }
//        enemyControl.killEnemy(withGesture: gesture, in: scene)
//    }
    
//    public func killEnemy(withGesture gesture: String) -> Int? {
//        guard let scene = self.scene else { return nil }
//
//        for node in scene.children {
//
//            if node.name == "Guard" && node.childNode(withName: gesture) != nil {
//                node.removeFromParent()
//                return Guards.pointValue
//            }
//        }
//
//        return nil
//    }
    
