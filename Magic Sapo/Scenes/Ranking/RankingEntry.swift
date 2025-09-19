//
//  RankingEntry.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 16/09/25.
//

import Foundation

/// Um struct simples para representar cada jogador no ranking.
/// O 'Identifiable' ajuda o SwiftUI a otimizar a lista.
struct RankingEntry: Identifiable {
    let id = UUID() // Identificador único para cada linha
    let rank: Int
    let playerName: String
    let score: String
}
