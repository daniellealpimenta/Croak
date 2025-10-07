//
//  GesturePredictor.swift
//  Magic Sapo
//
//  Created by Enzo Henrique Botelho Romão on 07/10/25.
//

import Foundation
import CoreML

protocol GesturePredictor {
    func prediction(poses: MLMultiArray) throws -> GesturePredictorOutput
}

protocol GesturePredictorOutput {
    var label: String { get }
    var labelProbabilities: [String: Double] { get }
}

extension MLModelPrime: GesturePredictor {
    func prediction(poses: MLMultiArray) throws -> GesturePredictorOutput {
        let modelInput = MLModelPrimeInput(poses: poses)
        return try self.prediction(input: modelInput)
    }
}

extension JPModel: GesturePredictor {
    func prediction(poses: MLMultiArray) throws -> GesturePredictorOutput {
        let modelInput = JPModelInput(poses: poses)
        return try self.prediction(input: modelInput)
    }
}

extension MLModelPrimeOutput: GesturePredictorOutput {}
extension JPModelOutput: GesturePredictorOutput {}

