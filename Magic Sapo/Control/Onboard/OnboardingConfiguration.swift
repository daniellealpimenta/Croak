//
//  OnboardingConfiguration.swift
//  Magic Sapo
//
//  Created by Pedro Santos on 05/09/25.
//

import Foundation

// A definição do "molde" de um passo vive aqui.
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

// Uma estrutura para fornecer os dados de configuração de forma estática.
struct OnboardingConfiguration {
    
    // O array com a sequência completa do tutorial agora mora aqui.
    static let steps: [OnboardingStep] = [
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
}
