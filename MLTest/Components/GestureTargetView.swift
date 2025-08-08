//
//  GestureTargetView.swift
//  MLTest
//
//  Created by Enzo Henrique Botelho Romão on 07/08/25.
//

import SwiftUI

struct GestureTargetView: View {
    let backgroundColor: Color
    let gestureName: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .frame(width: 180, height: 180)
            
            Image(gestureName)
                .resizable()
                .frame(width: 140, height: 140)
        }
    }
}

#Preview {
    GestureTargetView(backgroundColor: .red, gestureName: "Two")
}
