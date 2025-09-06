//
//  OnboardManager.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 05/09/25.
//

import SpriteKit
import Foundation

// MARK: - Modelo de Dados para o Onboarding
struct OnboardingStep {
    let dialogueText: String
    let frogImageName: String
    let enemyType: EnemyType?
    let requiredGestures: [String]
    let instructionImages: [String]
    
    enum EnemyType {
        case `guard`, thief
    }
}

class OnboardManager: NSObject {
    
    // MARK: - Propriedades de UI
    private var onboardingGuardInstructionOverlay: UIImageView?
    private var onboardingThiefInstructionOverlay1: UIImageView?
    private var onboardingThiefInstructionOverlay2: UIImageView?
    private var onboardingFrogImageView: UIImageView?
    private var onboardingDialogueBox: UIView?
    private var onboardingDialogueLabel: UILabel?
    
    // MARK: - Propriedades de Estado e Dependências
    private var currentStepIndex = 0
    private weak var view: SKView?
    private weak var enemySpawner: EnemySpawner?
    private weak var gestureManager: GestureDetectionManager?
    weak var delegate: OnboardDelegate?
    
    // MARK: - Configuração do Onboarding (Fonte da Verdade)
    private let onboardingSteps: [OnboardingStep] = [
        OnboardingStep(dialogueText: "Aí vem um guarda! Ele quer tomar o nosso livro mágico, faça o gesto que está na tela com sua mão para lançar uma magia nele!",
                       frogImageName: "talking-frog",
                       enemyType: .guard,
                       requiredGestures: ["Rock"],
                       instructionImages: ["instruction_rock"]),
        OnboardingStep(dialogueText: "Mais uma vez! Para derrotar cada guarda, imite o gesto da imagem em cima da sua cabeça.",
                       frogImageName: "normal-frog",
                       enemyType: .guard,
                       requiredGestures: ["Two"],
                       instructionImages: ["instruction_two"]),
        OnboardingStep(dialogueText: "Cuidado... Agora vem um ladrão. Você precisa fazer cada um dos 2 gestos para derrotá-lo!",
                       frogImageName: "worried-frog",
                       enemyType: .thief,
                       requiredGestures: ["OpenPalm", "Top"],
                       instructionImages: ["instruction_openpalm", "instruction_top"]),
        OnboardingStep(dialogueText: "Derrote esse outro ladrão com o que você aprendeu!",
                       frogImageName: "talking-frog2",
                       enemyType: .thief,
                       requiredGestures: ["L", "HangLose"],
                       instructionImages: ["instruction_l", "instruction_hanglose"]),
        OnboardingStep(dialogueText: "Muito bem! Agora você está pronto para começar de verdade. Atenção nos gestos dos inimigos!",
                       frogImageName: "enchanted-frog",
                       enemyType: nil,
                       requiredGestures: [],
                       instructionImages: [])
    ]
    
    // MARK: - Inicializador
    init(view: SKView, spawner: EnemySpawner, gestureManager: GestureDetectionManager) {
        self.view = view
        self.enemySpawner = spawner
        self.gestureManager = gestureManager
    }
    
    // MARK: - Funções Públicas (Controle do Onboarding)
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
            print("Ladrão atingido, mas ainda vivo. O jogador pode fazer o segundo gesto agora.")
            self.delegate?.EnterWaitingActionState()
        } else {
            removeOnboardingInstruction()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.proceedToNextOnboardingStep()
            }
        }
    }
    
    // MARK: - Lógica de Fluxo Privada
    private func showCurrentStep() {
        guard currentStepIndex < onboardingSteps.count else {
            completeOnboardingFlow()
            return
        }
        
        let currentStep = onboardingSteps[currentStepIndex]
        
        // Se o passo não tem inimigo (como a mensagem final), mostra só a UI e finaliza.
        guard let enemyType = currentStep.enemyType else {
            showOnboardingInstruction()
            completeOnboardingFlow()
            return
        }

        switch enemyType {
        case .guard:
            guard let gesture = currentStep.requiredGestures.first else { return }
            enemySpawner?.spawnOnboardingGuard(withGesture: gesture) { [weak self] enemy in
                self?.handleOnboardingEnemyReachedPosition(enemy: enemy)
            }
        case .thief:
            enemySpawner?.spawnOnboardingThief(withGestures: currentStep.requiredGestures) { [weak self] enemy in
                self?.handleOnboardingEnemyReachedPosition(enemy: enemy)
            }
        }
    }
    
    private func handleOnboardingEnemyReachedPosition(enemy: SKNode) {
        print("🛑 Enemy reached middle position, pausing and showing instruction")
        showOnboardingInstruction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("⏰ Delay de 1.5s concluído. Agora esperando a ação do jogador.")
            self.delegate?.EnterWaitingActionState()
        }
        self.gestureManager?.startDetection()
    }
    
    private func proceedToNextOnboardingStep() {
        currentStepIndex += 1
        showCurrentStep()
    }
    
    private func completeOnboardingFlow() {
        // Agenda a conclusão final.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) { [weak self] in
            guard let self = self else { return }
            print("🚀 Starting the real game now!")
            
            self.removeOnboardingInstruction()
            
            if let view = self.view {
                self.gestureManager?.moveCameraPreviewToNormalPosition(in: view)
            }
            
            self.delegate?.OnboardDidComplete()
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            self.enemySpawner?.startSpawningEnemies()
        }
    }

    // MARK: - Gerenciamento da UI

    // OnboardManager.swift

    private func showOnboardingInstruction() {
        guard let view = self.view, currentStepIndex < onboardingSteps.count else { return }
            
        let currentStep = onboardingSteps[currentStepIndex]
        removeOnboardingInstruction()
            
        // --- VALORES ADAPTATIVOS ---
        let dialogueBoxPadding: CGFloat = DeviceHelper.isIPad ? 70 : 20
        let dialogueBoxBottomPadding: CGFloat = DeviceHelper.isIPad ? 20 : 10
        let dialogueBoxHeight: CGFloat = DeviceHelper.isIPad ? 200 : 160
        let dialogueBoxCorner: CGFloat = DeviceHelper.isIPad ? 10 : 8

        let labelPaddingX: CGFloat = DeviceHelper.isIPad ? 44 : 20
        let labelPaddingY: CGFloat = DeviceHelper.isIPad ? 30 : 15
        let labelFontSize: CGFloat = DeviceHelper.isIPad ? 32 : 20
            
        let frogImageWidth: CGFloat = DeviceHelper.isIPad ? 300 : 170
        let frogImageHeight: CGFloat = DeviceHelper.isIPad ? 300 : 170
        let frogPaddingLeft: CGFloat = DeviceHelper.isIPad ? 90 : 10
            
        let instructionImageSize: CGFloat = DeviceHelper.isIPad ? 200 : 95
        
        // --- Caixa de Diálogo ---
        let dialogueBox = UIView()
        dialogueBox.backgroundColor = .white
        dialogueBox.layer.cornerRadius = dialogueBoxCorner
        dialogueBox.layer.borderColor = UIColor.black.cgColor
        dialogueBox.layer.borderWidth = 4
        dialogueBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dialogueBox)
        self.onboardingDialogueBox = dialogueBox
            
        NSLayoutConstraint.activate([
            dialogueBox.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: dialogueBoxPadding),
            dialogueBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -dialogueBoxPadding),
            dialogueBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -dialogueBoxBottomPadding),
            dialogueBox.heightAnchor.constraint(equalToConstant: dialogueBoxHeight)
        ])

        // --- Texto do Diálogo ---
        let dialogueLabel = UILabel()
        dialogueLabel.text = currentStep.dialogueText
        dialogueLabel.textColor = .black
        dialogueLabel.font = UIFont(name: "Ari-W9500", size: labelFontSize) ?? .systemFont(ofSize: labelFontSize, weight: .bold)
        dialogueLabel.numberOfLines = 0
        dialogueLabel.textAlignment = .center
        dialogueLabel.translatesAutoresizingMaskIntoConstraints = false
        dialogueBox.addSubview(dialogueLabel)
        self.onboardingDialogueLabel = dialogueLabel
            
        // --- Imagem do Sapo ---
        let frogImageView = UIImageView(image: UIImage(named: currentStep.frogImageName))
        frogImageView.contentMode = .scaleAspectFit
        frogImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frogImageView)
        self.onboardingFrogImageView = frogImageView

        if DeviceHelper.isIPad {
            NSLayoutConstraint.activate([
                frogImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: frogPaddingLeft),
                frogImageView.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                frogImageView.widthAnchor.constraint(equalToConstant: frogImageWidth),
                frogImageView.heightAnchor.constraint(equalToConstant: frogImageHeight)
            ])
        } else {
            NSLayoutConstraint.activate([
                frogImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: frogPaddingLeft),
                frogImageView.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                frogImageView.widthAnchor.constraint(equalToConstant: frogImageWidth),
                frogImageView.heightAnchor.constraint(equalToConstant: frogImageHeight)
            ])
        }

            
        // --- Imagens de Instrução ---
        if currentStep.instructionImages.count > 1 { // Caso do Ladrão (2 imagens)
            let firstIV = createInstructionImageView(imageName: currentStep.instructionImages[0], size: instructionImageSize, in: view)
            let secondIV = createInstructionImageView(imageName: currentStep.instructionImages[1], size: instructionImageSize, in: view)
            
            if DeviceHelper.isIPad {
                let paddingDireita: CGFloat = -100
                NSLayoutConstraint.activate([
                    secondIV.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: paddingDireita),
                    secondIV.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                    firstIV.trailingAnchor.constraint(equalTo: secondIV.leadingAnchor),
                    firstIV.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor)
                ])
            } else {
                let paddingDireita: CGFloat = -25
                let horizontalSpacing: CGFloat = 20
                
                NSLayoutConstraint.activate([
                    // Alinha ambas na borda direita
                    secondIV.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: paddingDireita),
                    firstIV.trailingAnchor.constraint(equalTo: secondIV.leadingAnchor, constant: horizontalSpacing),
                    
                    // "Gruda" a imagem de baixo no topo da caixa de diálogo
                    secondIV.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor, constant: 0),
                    
                    // Coloca a imagem de cima sobre a de baixo
                    firstIV.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor, constant: 0)
                ])
            }
            
            self.onboardingThiefInstructionOverlay1 = firstIV
            self.onboardingThiefInstructionOverlay2 = secondIV

        } else if let imageName = currentStep.instructionImages.first { // Caso do Guarda (1 imagem)
            let iv = createInstructionImageView(imageName: imageName, size: instructionImageSize, in: view)
            
            if DeviceHelper.isIPad {
                let paddingDireita: CGFloat = -172
                NSLayoutConstraint.activate([
                    iv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: paddingDireita),
                    iv.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor)
                ])
            } else {
                
                let paddingDireita: CGFloat = -40
                
                NSLayoutConstraint.activate([
                    // Alinha na borda direita
                    iv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: paddingDireita),
                    
                    // "Gruda" a base da imagem no topo da caixa de diálogo
                    iv.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor, constant: 0)
                ])
            }
            
            self.onboardingGuardInstructionOverlay = iv
        }
        
        // O texto sempre ocupa a caixa inteira
        NSLayoutConstraint.activate([
            dialogueLabel.leadingAnchor.constraint(equalTo: dialogueBox.leadingAnchor, constant: labelPaddingX),
            dialogueLabel.trailingAnchor.constraint(equalTo: dialogueBox.trailingAnchor, constant: -labelPaddingX),
            dialogueLabel.topAnchor.constraint(equalTo: dialogueBox.topAnchor, constant: labelPaddingY),
            dialogueLabel.bottomAnchor.constraint(equalTo: dialogueBox.bottomAnchor, constant: -labelPaddingY)
        ])
        
            
        // --- Animação de Entrada ---
        onboardingGuardInstructionOverlay?.alpha = 0
        onboardingThiefInstructionOverlay1?.alpha = 0
        onboardingThiefInstructionOverlay2?.alpha = 0
        frogImageView.alpha = 0
        dialogueBox.alpha = 0
            
        UIView.animate(withDuration: 0.3) {
            self.onboardingGuardInstructionOverlay?.alpha = 1.0
            self.onboardingThiefInstructionOverlay1?.alpha = 1.0
            self.onboardingThiefInstructionOverlay2?.alpha = 1.0
            frogImageView.alpha = 1.0
            dialogueBox.alpha = 1.0
        }
    }
    // MARK: FIm da show
    
    // Função auxiliar para criar as ImageViews de instrução e evitar código repetido
    private func createInstructionImageView(imageName: String, size: CGFloat, in view: UIView) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size),
            imageView.heightAnchor.constraint(equalToConstant: size)
        ])
        
        return imageView
    }

    private func removeOnboardingInstruction() {
        let frogToRemove = self.onboardingFrogImageView
        let dialogueBoxToRemove = self.onboardingDialogueBox
        let guardInstructionToRemove = self.onboardingGuardInstructionOverlay
        let thiefInstructionToRemove1 = self.onboardingThiefInstructionOverlay1
        let thiefInstructionToRemove2 = self.onboardingThiefInstructionOverlay2
        
        self.onboardingGuardInstructionOverlay = nil
        self.onboardingThiefInstructionOverlay1 = nil
        self.onboardingThiefInstructionOverlay2 = nil
        self.onboardingFrogImageView = nil
        self.onboardingDialogueBox = nil
        self.onboardingDialogueLabel = nil

        UIView.animate(withDuration: 0.3, animations: {
            frogToRemove?.alpha = 0
            dialogueBoxToRemove?.alpha = 0
            guardInstructionToRemove?.alpha = 0
            thiefInstructionToRemove1?.alpha = 0
            thiefInstructionToRemove2?.alpha = 0
        }) { (finished) in
            guard finished else { return }
            frogToRemove?.removeFromSuperview()
            dialogueBoxToRemove?.removeFromSuperview()
            guardInstructionToRemove?.removeFromSuperview()
            thiefInstructionToRemove1?.removeFromSuperview()
            thiefInstructionToRemove2?.removeFromSuperview()
        }
    }
}
