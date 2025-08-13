//
//  EnemySpawner.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 13/08/25.
//
import Foundation
import SpriteKit

class EnemySpawner {
    
    private let availableEnemies: [Enemy.Type] = [Guards.self]
    
    private let enemyControl: EnemyControl
    weak var scene: SKScene?
    var spawnTimer: Timer?
    
    init(scene: SKScene) {
        self.scene = scene
        self.enemyControl = EnemyControl()
    }

    func startSpawningEnemies() {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self, let scene = self.scene else { return }
            
            if let randomEnemyType = self.availableEnemies.randomElement() {
                self.enemyControl.createEnemy(ofType: randomEnemyType, in: scene)
            }
        }
    }
    
    func stopSpawningEnemies() {
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
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
    
    // CORRIGIDO: Agora delega a chamada para enemyControl e retorna seu resultado
    public func killEnemy(withGesture gesture: String) -> Int? {
        guard let scene = self.scene else { return nil }
        // Chama a função em EnemyControl e retorna diretamente o que ela devolver
        return enemyControl.killEnemy(withGesture: gesture, in: scene)
    }
}
