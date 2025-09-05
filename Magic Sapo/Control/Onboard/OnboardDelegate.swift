//
//  OnboardDelegate.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 05/09/25.
//

import Foundation

protocol OnboardDelegate: AnyObject {
    func EnterWaitingActionState()
    
    func PlayerDidCorrectGesture()
    func OnboardDidComplete()
}
