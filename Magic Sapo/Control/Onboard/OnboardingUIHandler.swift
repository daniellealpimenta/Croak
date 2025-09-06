//
//  OnboardingUIHandler.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 05/09/25.
//

import UIKit

class OnboardingUIHandler {
    
    // MARK: - Propriedades de UI
    // Todas as propriedades de UI do onboarding foram movidas para cá.
    private var guardInstructionOverlay: UIImageView?
    private var thiefInstructionOverlay1: UIImageView?
    private var thiefInstructionOverlay2: UIImageView?
    private var frogImageView: UIImageView?
    private var dialogueBox: UIView?
    private var dialogueLabel: UILabel?
    
    private weak var parentView: UIView?
    
    // MARK: - Inicializador
    init(parentView: UIView) {
        self.parentView = parentView
    }
    
    // MARK: - Métodos Públicos
    
    /// Constrói, posiciona e anima a UI para um passo específico do onboarding.
    func show(for step: OnboardingStep) {
        guard let view = parentView else { return }
        
        // Garante que qualquer UI anterior seja removida antes de mostrar a nova.
        hide()
        
        // --- Caixa de Diálogo ---
        let dialogueBox = UIView()
        dialogueBox.backgroundColor = .white
        dialogueBox.layer.cornerRadius = 10
        dialogueBox.layer.borderColor = UIColor.black.cgColor
        dialogueBox.layer.borderWidth = 4
        dialogueBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dialogueBox)
        self.dialogueBox = dialogueBox
        
        let padding: CGFloat = 70
        let dialogueBoxPadding: CGFloat = 20
        let dialogueBoxHeight: CGFloat = 200
        NSLayoutConstraint.activate([
            dialogueBox.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            dialogueBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            dialogueBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -dialogueBoxPadding),
            dialogueBox.heightAnchor.constraint(equalToConstant: dialogueBoxHeight)
        ])
        
        // --- Texto do Diálogo ---
        let dialogueLabel = UILabel()
        dialogueLabel.text = step.dialogueText
        dialogueLabel.textColor = .black
        dialogueLabel.font = UIFont(name: "Ari-W9500", size: 32) ?? .systemFont(ofSize: 32, weight: .bold)
        dialogueLabel.numberOfLines = 0
        dialogueLabel.textAlignment = .center
        dialogueLabel.translatesAutoresizingMaskIntoConstraints = false
        dialogueBox.addSubview(dialogueLabel)
        self.dialogueLabel = dialogueLabel
        
        let labelPaddingX: CGFloat = 44
        let labelPaddingY: CGFloat = 30
        NSLayoutConstraint.activate([
            dialogueLabel.topAnchor.constraint(equalTo: dialogueBox.topAnchor, constant: labelPaddingY),
            dialogueLabel.leadingAnchor.constraint(equalTo: dialogueBox.leadingAnchor, constant: labelPaddingX),
            dialogueLabel.trailingAnchor.constraint(equalTo: dialogueBox.trailingAnchor, constant: -labelPaddingX),
            dialogueLabel.bottomAnchor.constraint(equalTo: dialogueBox.bottomAnchor, constant: -labelPaddingY)
        ])
        
        // --- Imagens de Instrução ---
        if step.instructionImages.count > 1 {
            let firstIV = UIImageView(image: UIImage(named: step.instructionImages[0]))
            let secondIV = UIImageView(image: UIImage(named: step.instructionImages[1]))
            
            [firstIV, secondIV].forEach {
                $0.contentMode = .scaleAspectFit
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }
            
            let imageWidth: CGFloat = 200
            let imageHeight: CGFloat = 200
            let paddingRight: CGFloat = 100
            
            self.thiefInstructionOverlay1 = firstIV
            NSLayoutConstraint.activate([
                firstIV.trailingAnchor.constraint(equalTo: secondIV.leadingAnchor),
                firstIV.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                firstIV.widthAnchor.constraint(equalToConstant: imageWidth),
                firstIV.heightAnchor.constraint(equalToConstant: imageHeight)
            ])
            
            self.thiefInstructionOverlay2 = secondIV
            NSLayoutConstraint.activate([
                secondIV.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -paddingRight),
                secondIV.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                secondIV.widthAnchor.constraint(equalToConstant: imageWidth),
                secondIV.heightAnchor.constraint(equalToConstant: imageHeight)
            ])
            
        } else if let imageName = step.instructionImages.first {
            let iv = UIImageView(image: UIImage(named: imageName))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(iv) // Adiciona na view principal
            self.guardInstructionOverlay = iv
            
            let imageWidth: CGFloat = 200
            let imageHeight: CGFloat = 200
            let paddingRight: CGFloat = 172
            
            NSLayoutConstraint.activate([
                iv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -paddingRight),
                iv.bottomAnchor.constraint(equalTo: dialogueBox.topAnchor),
                iv.widthAnchor.constraint(equalToConstant: imageWidth),
                iv.heightAnchor.constraint(equalToConstant: imageHeight)
            ])
        }
        
        // --- Imagem do Sapo ---
        let frogImageView = UIImageView(image: UIImage(named: step.frogImageName))
        frogImageView.contentMode = .scaleAspectFit
        frogImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frogImageView)
        self.frogImageView = frogImageView
        
        let frogImageWidth: CGFloat = 300
        let frogImageHeight: CGFloat = 300
        let frogPaddingLeft: CGFloat = 90
        NSLayoutConstraint.activate([
            frogImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: frogPaddingLeft),
            frogImageView.bottomAnchor.constraint(equalTo: dialogueBox.bottomAnchor, constant: -dialogueBoxHeight),
            frogImageView.widthAnchor.constraint(equalToConstant: frogImageWidth),
            frogImageView.heightAnchor.constraint(equalToConstant: frogImageHeight)
        ])
        
        // --- Animação de Entrada ---
        frogImageView.alpha = 0
        dialogueBox.alpha = 0
        // Certifique-se de que as imagens de instrução também participem da animação se desejar
        guardInstructionOverlay?.alpha = 0
        thiefInstructionOverlay1?.alpha = 0
        thiefInstructionOverlay2?.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            frogImageView.alpha = 1.0
            dialogueBox.alpha = 1.0
            self.guardInstructionOverlay?.alpha = 1.0
            self.thiefInstructionOverlay1?.alpha = 1.0
            self.thiefInstructionOverlay2?.alpha = 1.0
        }
    }
    
    /// Anima e remove todos os elementos da UI do onboarding da tela.
    func hide() {
        let elementsToRemove = [
            frogImageView,
            dialogueBox,
            guardInstructionOverlay,
            thiefInstructionOverlay1,
            thiefInstructionOverlay2
        ]
        
        // Limpa as referências
        self.frogImageView = nil
        self.dialogueBox = nil
        self.dialogueLabel = nil
        self.guardInstructionOverlay = nil
        self.thiefInstructionOverlay1 = nil
        self.thiefInstructionOverlay2 = nil
        
        // Anima a saída
        UIView.animate(withDuration: 0.3, animations: {
            elementsToRemove.forEach { $0?.alpha = 0 }
        }) { (finished) in
            guard finished else { return }
            elementsToRemove.forEach { $0?.removeFromSuperview() }
        }
    }
}
