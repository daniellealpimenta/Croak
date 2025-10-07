//
//  GestureDetection.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 16/08/25.
//

import Foundation

protocol GestureDetectionDelegate: AnyObject {
    func gestureDetected(_ gesture: String, confidence: Double)
    func gestureDetectionLost()
    
    func cameraWillExpand()
    func cameraDidShrink()
}
