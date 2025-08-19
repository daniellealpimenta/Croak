//
//  OrientationHelper.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 19/08/25.
//

import Foundation
import UIKit

struct OrientationHelper {
    static var currentInterfaceOrientation: UIInterfaceOrientation {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return scene.interfaceOrientation
        }
        return .landscapeRight // Default para iPad
    }
    
    static var isLandscape: Bool {
        let orientation = currentInterfaceOrientation
        return orientation == .landscapeLeft || orientation == .landscapeRight
    }
    
    static var isLandscapeLeft: Bool {
        return currentInterfaceOrientation == .landscapeLeft
    }
    
    static var isLandscapeRight: Bool {
        return currentInterfaceOrientation == .landscapeRight
    }
}
