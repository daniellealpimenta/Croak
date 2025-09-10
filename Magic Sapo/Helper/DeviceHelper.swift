//
//  DeviceHelper.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 16/08/25.
//

import UIKit

struct DeviceHelper {
    
    enum DeviceType {
        case iPhone
        case iPad
        case unknown
    }
    
    static var current: DeviceType {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .iPhone
        case .pad:
            return .iPad
        default:
            return .unknown
        }
    }
    
    static var isIPhone: Bool {
        return current == .iPhone
    }
    
    static var isIPad: Bool {
        return current == .iPad
    }
    
    // Fatores de escala baseados no dispositivo
    static var scaleFactor: CGFloat {
        switch current {
        case .iPhone:
            return 0.7 // iPhone usa 70% do tamanho do iPad
        case .iPad:
            return 1.0 // iPad usa tamanho normal
        case .unknown:
            return 1.0
        }
    }
    
    // Espaçamento adaptativo
    static var spacing: CGFloat {
        switch current {
        case .iPhone:
            return 20
        case .iPad:
            return 50
        case .unknown:
            return 30
        }
    }
}
