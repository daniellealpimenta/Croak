//
//  OnboardManager.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 05/09/25.
//

import SpriteKit
import Foundation

class OnboardManager: NSObject {
    
    // MARK: - Propriedades
    private var currentStepIndex = 0
    private let onboardingSteps = OnboardingConfiguration.steps // Pega os dados do nosso novo arquivo!
    
    // Dependências externas
    private weak var enemySpawner: EnemySpawner?
    private weak var gestureManager: GestureDetectionManager?
    weak var delegate: OnboardDelegate?
    
    // Dependência interna para a UI
    private let uiHandler: OnboardingUIHandler
    
    // MARK: - Inicializador
    init(view: SKView, spawner: EnemySpawner, gestureManager: GestureDetectionManager) {
        self.enemySpawner = spawner
        self.gestureManager = gestureManager
        self.uiHandler = OnboardingUIHandler(parentView: view) // Cria o nosso gerenciador de UI
        super.init()
    }
    
    // MARK: - Controle do Fluxo
    func startOnboarding() {
        print("🎓 Iniciando onboarding...")
        currentStepIndex = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showCurrentStep()
        }
    }
    
    func handleOnboardingGestureSuccess() {
        delegate?.PlayerDidCorrectGesture()
        
        if self.enemySpawner!.hasActiveEnemies {
            delegate?.EnterWaitingActionState()
        } else {
            uiHandler.hide() // Pede para a UI sumir
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.proceedToNextOnboardingStep()
            }
        }
    }
    
    private func showCurrentStep() {
        guard currentStepIndex < onboardingSteps.count else {
            completeOnboardingFlow()
            return
        }
        
        let currentStep = onboardingSteps[currentStepIndex]
        uiHandler.show(for: currentStep) // Pede para a UI aparecer com os dados do passo atual
        
        guard let enemyType = currentStep.enemyType else {
            completeOnboardingFlow()
            return
        }

        switch enemyType {
        case .guard:
            guard let gesture = currentStep.requiredGestures.first else { return }
            enemySpawner?.spawnOnboardingGuard(withGesture: gesture, completion: handleOnboardingEnemyReachedPosition)
        case .thief:
            enemySpawner?.spawnOnboardingThief(withGestures: currentStep.requiredGestures, completion: handleOnboardingEnemyReachedPosition)
        }
    }
    
    private func handleOnboardingEnemyReachedPosition(enemy: SKNode) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.delegate?.EnterWaitingActionState()
        }
        self.gestureManager?.startDetection()
    }
    
    private func proceedToNextOnboardingStep() {
        currentStepIndex += 1
        showCurrentStep()
    }
    
    private func completeOnboardingFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) { [weak self] in
            guard let self = self else { return }
            
            self.uiHandler.hide()
            self.delegate?.OnboardDidComplete()
        }
    }
}
