//
//  OnboardManager.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 05/09/25.
//

import SpriteKit
import Foundation


class OnboardManager: NSObject {
    
    private var currentOnboardingGestureIndex = 0
    
    private var onboardingGuardInstructionOverlay: UIImageView?
    private var onboardingThiefInstructionOverlay1: UIImageView?
    private var onboardingThiefInstructionOverlay2: UIImageView?
    private var onboardingInstructionBox: UIView?
    private var onboardingFrogImageView: UIImageView?
    private var onboardingDialogueBox: UIView?
    private var onboardingDialogueLabel: UILabel?
    
    private let onboardingGuardGestures = ["Rock", "Two"]
    
    private weak var view: SKView?
    private weak var enemySpawner: EnemySpawner?
    private weak var gestureManager: GestureDetectionManager?
    
    weak var delegate: OnboardDelegate?
    
    init(view: SKView, spawner: EnemySpawner, gestureManager: GestureDetectionManager) {
        self.view = view
        self.enemySpawner = spawner
        self.gestureManager = gestureManager
    }
    
    // Funções
    
    func startOnboarding() {
        print("🎓 Iniciando onboarding...")
        currentOnboardingGestureIndex = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.spawnOnboardingEnemy()
        }
    }

    func spawnOnboardingEnemy() {
        // Verifica se o índice atual está dentro da lista de gestos dos guardas
        if currentOnboardingGestureIndex < 2 {
            // --- Lógica para spawnar um GUARDA ---
            let currentGesture = onboardingGuardGestures[currentOnboardingGestureIndex]
            print("🎯 Spawning onboarding GUARD with gesture: \(currentGesture)")
            
            enemySpawner?.spawnOnboardingGuard(withGesture: currentGesture) { [weak self] enemy in
                self?.handleOnboardingEnemyReachedPosition(enemy: enemy)
                print("Current onboarding index: \(String(describing: self?.currentOnboardingGestureIndex))")
                print("OnboardingGuardGesture count: \(String(describing: self?.onboardingGuardGestures.count))")
            }
        }
        // Se já passamos por todos os guardas, é a vez do ladrão
        else if currentOnboardingGestureIndex >= 2 && currentOnboardingGestureIndex < 4 {
            // --- Lógica para spawnar o LADRÃO ---
            let currentFirstGesture: String
            let currentSecondGesture: String
            
            if currentOnboardingGestureIndex == 2 {
                currentFirstGesture = "OpenPalm"
                currentSecondGesture = "Top"
            } else {
                currentFirstGesture = "L"
                currentSecondGesture = "HangLose"
            }
            
            let currentGestures = [currentFirstGesture, currentSecondGesture]
            
            enemySpawner?.spawnOnboardingThief(withGestures: currentGestures) { [weak self] enemy in
                // Usamos uma string especial "ThiefIntro" para acionar o diálogo correto
                self?.handleOnboardingEnemyReachedPosition(enemy: enemy)
            }
        }
        // Se já passamos pelo ladrão, o onboarding acabou
        else {
            completeOnboarding()
        }
    }

    func handleOnboardingEnemyReachedPosition(enemy: SKNode) {
        print("🛑 Enemy reached middle position, pausing and showing instruction")
        
        // Mostra instrução visual
        showOnboardingInstruction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("⏰ Delay de 1.5s concluído. Agora esperando a ação do jogador.")
            self.delegate?.EnterWaitingActionState()
        }
        
        self.gestureManager?.startDetection()
    }

    private func showOnboardingInstruction() {
        guard let view = self.view else { return }
        
        removeOnboardingInstruction()
        
        let padding: CGFloat = 70       // Espaçamento da borda direita da tel
        
        // Caixa de diálogo
        
        let dialogueBox = UIView()
        dialogueBox.backgroundColor = UIColor.white
        dialogueBox.layer.cornerRadius = 10
        dialogueBox.layer.borderColor = UIColor.black.cgColor
        dialogueBox.layer.borderWidth = 4
        dialogueBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dialogueBox)
        self.onboardingDialogueBox = dialogueBox
        
        let dialogueBoxPadding: CGFloat = 20 // Padding das bordas da tela
        let dialogueBoxHeight: CGFloat = 200 // Altura da caixa de diálogo
        
        NSLayoutConstraint.activate([
            dialogueBox.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            dialogueBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            dialogueBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -dialogueBoxPadding),
            dialogueBox.heightAnchor.constraint(equalToConstant: dialogueBoxHeight)
        ])
        
        // Texto do diálogo
        
        let dialogueLabel = UILabel()
        let dialogueText = getDialogueLabelText()
        dialogueLabel.text = dialogueText
        dialogueLabel.textColor = .black
        dialogueLabel.font = UIFont(name: "Ari-W9500", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold)
        dialogueLabel.numberOfLines = 0 // Permite múltiplas linhas
        dialogueLabel.textAlignment = .center // Centraliza o texto
        dialogueLabel.translatesAutoresizingMaskIntoConstraints = false
        dialogueBox.addSubview(dialogueLabel) // Adiciona na caixa de diálogo, não na view principal
        self.onboardingDialogueLabel = dialogueLabel
        
        let labelPaddingX: CGFloat = 44 // Padding interno da label dentro da caixa
        let labelPaddingY: CGFloat = 30
        
        NSLayoutConstraint.activate([
            dialogueLabel.topAnchor.constraint(equalTo: dialogueBox.topAnchor, constant: labelPaddingY),
            dialogueLabel.leadingAnchor.constraint(equalTo: dialogueBox.leadingAnchor, constant: labelPaddingX),
            dialogueLabel.trailingAnchor.constraint(equalTo: dialogueBox.trailingAnchor, constant: -labelPaddingX),
            dialogueLabel.bottomAnchor.constraint(equalTo: dialogueBox.bottomAnchor, constant: -labelPaddingY)
        ])
        
        // Instrução
        
        if currentOnboardingGestureIndex == 2 || currentOnboardingGestureIndex == 3 {
            let firstInstructionImageView = UIImageView()
            let secondInstructionImageView = UIImageView()
            let instructionImageNames = getInstructionImageName()
            
            firstInstructionImageView.image = UIImage(named: instructionImageNames[0])
            firstInstructionImageView.contentMode = .scaleAspectFit
            firstInstructionImageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(firstInstructionImageView)
            
            secondInstructionImageView.image = UIImage(named: instructionImageNames[1])
            secondInstructionImageView.contentMode = .scaleAspectFit
            secondInstructionImageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(secondInstructionImageView)
            
            let InstructionImageWidth: CGFloat = 200 // Largura do mago
            let InstructionImageHeight: CGFloat = 200 // Altura do mago
            let InstructionPaddingRight: CGFloat = 100  // Padding da esquerda
            
            self.onboardingThiefInstructionOverlay1 = firstInstructionImageView
            
            NSLayoutConstraint.activate([
                firstInstructionImageView.trailingAnchor.constraint(equalTo: secondInstructionImageView.leadingAnchor),
                firstInstructionImageView.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                firstInstructionImageView.widthAnchor.constraint(equalToConstant: InstructionImageWidth),
                firstInstructionImageView.heightAnchor.constraint(equalToConstant: InstructionImageHeight)
            ])
            
            self.onboardingThiefInstructionOverlay2 = secondInstructionImageView
            
            NSLayoutConstraint.activate([
                secondInstructionImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -InstructionPaddingRight),
                secondInstructionImageView.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                secondInstructionImageView.widthAnchor.constraint(equalToConstant: InstructionImageWidth),
                secondInstructionImageView.heightAnchor.constraint(equalToConstant: InstructionImageHeight)
            ])
            
        } else {
            let instructionImageView = UIImageView()
            let instructionImageName = getInstructionImageName()
            instructionImageView.image = UIImage(named: instructionImageName[0])
            instructionImageView.contentMode = .scaleAspectFit
            instructionImageView.translatesAutoresizingMaskIntoConstraints = false
            dialogueBox.addSubview(instructionImageView)
            self.onboardingGuardInstructionOverlay = instructionImageView
            
            let InstructionImageWidth: CGFloat = 200 // Largura do mago
            let InstructionImageHeight: CGFloat = 200 // Altura do mago
            let InstructionPaddingRight: CGFloat = 172  // Padding da esquerda
            
            NSLayoutConstraint.activate([
                instructionImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -InstructionPaddingRight),
                instructionImageView.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                instructionImageView.widthAnchor.constraint(equalToConstant: InstructionImageWidth),
                instructionImageView.heightAnchor.constraint(equalToConstant: InstructionImageHeight)
            ])
        }
        
        // Sapo falando
        
        let frogImageView = UIImageView()
        let frogImageName = getFrogImageName()
        frogImageView.image = UIImage(named: frogImageName)
        frogImageView.contentMode = .scaleAspectFit
        frogImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frogImageView)
        self.onboardingFrogImageView = frogImageView
            
        let frogImageWidth: CGFloat = 300 // Largura do mago
        let frogImageHeight: CGFloat = 300 // Altura do mago
        let frogPaddingLeft: CGFloat = 90  // Padding da esquerda
        
        NSLayoutConstraint.activate([
            frogImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: frogPaddingLeft),
            frogImageView.bottomAnchor.constraint(equalTo: dialogueBox.bottomAnchor, constant: -dialogueBoxHeight),
            frogImageView.widthAnchor.constraint(equalToConstant: frogImageWidth),
            frogImageView.heightAnchor.constraint(equalToConstant: frogImageHeight)
        ])
        
        // Anima aparição dos elementos
//        instructionBox.alpha = 0
//        instructionImageView.alpha = 0
        frogImageView.alpha = 0
        dialogueBox.alpha = 0
        dialogueLabel.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
//            instructionBox.alpha = 1.0
//            instructionImageView.alpha = 1.0
            frogImageView.alpha = 1.0
            dialogueBox.alpha = 1.0
            dialogueLabel.alpha = 1.0
        }
    }

    private func getInstructionImageName() -> [String] {
        switch currentOnboardingGestureIndex {
        case 0:
            return ["instruction_rock"]
        case 1:
            return ["instruction_two"]
        case 2:
            return ["instruction_openpalm", "instruction_top"]
        case 3:
            return ["instruction_l", "instruction_hanglose"]
        default:
            return ["instruction_default"]
        }
    }
    
    private func getFrogImageName() -> String {
        switch currentOnboardingGestureIndex {
        case 0:
            return "talking-frog"
        case 1:
            return "normal-frog"
        case 2:
            return "worried-frog"
        case 3:
            return "talking-frog2"
        case 4:
            return "enchanted-frog"
        default:
            return "talking-frog"
        }
    }
    
    private func getDialogueLabelText() -> String {
        switch currentOnboardingGestureIndex {
        case 0:
            return "Aí vem um guarda! Ele quer tomar o nosso livro mágico, faça o gesto que está na tela com sua mão para lançar uma magia nele!"
        case 1:
            return "Mais uma vez! Para derrotar cada guarda, imite o gesto da imagem em cima da sua cabeça."
        case 2:
            return "Cuidado... Agora vem um ladrão. Você precisa fazer cada um dos 2 gestos para derrotá-lo!"
        case 3:
            return "Derrote esse outro ladrão com o que você aprendeu!"
        case 4:
            return "Muito bem! Agora você está pronto para começar de verdade. Atenção nos gestos dos inimigos!"
        default:
            return "Faça o gesto para derrotar o guarda!"
        }
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

    func handleOnboardingGestureSuccess() {
//        print("✅ Player made correct gesture during onboarding!")
        
//        self.isPaused = false
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

    private func proceedToNextOnboardingStep() {
        currentOnboardingGestureIndex += 1
        
        if currentOnboardingGestureIndex <= 2 {
            spawnOnboardingEnemy()
        } else if currentOnboardingGestureIndex <= 4 {
            spawnOnboardingEnemy()
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
//        print("🎉 Onboarding completed! Showing final dialogue.")
        
        // 1. Limpa qualquer instrução anterior.
        removeOnboardingInstruction()
        
        // 2. Mostra o diálogo final.
        showOnboardingInstruction()
        
        // 3. Agenda o início do jogo para daqui a 3 segundos.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) { [weak self] in
            guard let self = self else { return }
            
            print("🚀 Starting the real game now!")
            
            // Remove a mensagem final
            self.removeOnboardingInstruction()
            
            // Move a câmera para a posição final
            if let view = self.view {
                self.gestureManager?.moveCameraPreviewToNormalPosition(in: view)
            }
            
            delegate?.OnboardDidComplete()
            
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            
            self.enemySpawner?.startSpawningEnemies()
        }
    }
    
    
}
