//
//  RankingView.swift
//  Magic Sapo
//
//  Created by Daniel Leal Pimenta on 16/09/25.
//

import SwiftUI

struct RankingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let entries: [RankingEntry]

    var body: some View {
        ZStack {
            Image("ranking_iphone")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            // VStack principal para organizar a tela verticalmente: Título, Moldura com Lista, Botão
            VStack(alignment: .center ,spacing: 15) {
                
                Text("Recorde Semanal")
                    .font(.custom("Ari-W9500Bold", size: 32))
                    .fontWeight(.heavy)
                    .foregroundColor(Color(red: 0.8, green: 0.7, blue: 0.5))
                    .shadow(color: .black, radius: 2, x: 1, y: 1)
                    .padding(.top)
                    .zIndex(10)


                // --- A MOLDURA COM A LISTA DENTRO ---
                // Usamos uma ZStack para colocar a lista SOBRE a imagem da moldura
                ZStack {
                    
                    // CAMADA 1: A IMAGEM DA MOLDURA (ranking_item)
                    Image("ranking_item")
                        .resizable()
                        .scaledToFit() // Garante que a moldura mantenha sua proporção
                        .scaleEffect(x: 1.6, y: 1.8)
                        .padding(.trailing, 10)
                        

                    // CAMADA 2: A LISTA
                    List(entries) { entry in
                        HStack(alignment: .center, spacing: 8) {
                            Text("\(entry.rank)°")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
//                                .frame(width: 80, alignment: .leading)
                            
                            Text(entry.playerName)
                                .font(.body)
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Spacer()
                            
                            Text(entry.score)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .listRowBackground(
                            Image("prateleira")
                                .resizable()
                                .scaledToFill()
                        )
                        .listRowSeparator(.hidden)
                    }
                    .frame(width: 305,height: 405)
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    // **A MÁGICA ACONTECE AQUI:**
                    // Adicionamos um padding para "encolher" a lista e fazê-la caber dentro da moldura.
                    // Você pode ajustar esses valores para um encaixe perfeito.
                    .padding(.top, 115)
                    
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    ZStack {
                        Image("backButton")
                            .resizable()
                            .scaledToFit()
                        
                        Text("Voltar")
                            .font(.custom("Ari-W9500Bold", size: 24)) // Dica: Use um só modificador de fonte
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                    }
                }
                .frame(width: 200, height: 60)
                .padding(.bottom)
            }
//            .padding(.horizontal, 40) // Espaçamento lateral para a VStack inteira
        }
    }
}
