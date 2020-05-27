//
//  RLAgent.swift
//  connect4
//
//  Created by Nanway Chen on 28/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import Foundation
import TensorFlowLite

private func colorToNum(color : Color) -> Int {
    switch color {
    case .red:
        return 1
    case .blu:
        return 2
    }
}

final class RLAgent : Agent {
    private static let redAgent = FileInfo(name : "red_brain", ext: ".tflite")
    private static let blueAgent = FileInfo(name : "blubrain", ext: ".tflite")
    private static var agents = [String : RLAgent]()
    
    static func getAgent(modelName: String, color : Color, randomness: Int) -> RLAgent? {
        
        let fileInfo = DataModel.getDataModel().modelNameToPath[modelName]
        
        guard var fileInfoActual = fileInfo else {
            print("Loading a model that wasn't found")
            exit(EXIT_FAILURE)
        }
        
        var modelPath : String
        switch color {
        case .blu:
            modelPath = DataModel.bluPathPrefix + "_" + fileInfoActual.name
        default:
            modelPath = DataModel.redPathPrefix + "_" + fileInfoActual.name
        }
        
        guard let agent = RLAgent.agents[modelPath] else {
            fileInfoActual.name = modelPath
            return RLAgent(modelInfo: fileInfoActual, randomness: randomness)
        }
        
        agent.randomness = randomness
        return agent
    }
    
    private var interpreter : Interpreter
    var randomness = 0
    
    private init?(modelInfo : FileInfo, randomness: Int) {
        guard let modelPath = Bundle.main.path(forResource: modelInfo.name, ofType: modelInfo.ext) else {
            print("Failed to load model with name: \(modelInfo)")
            return nil
        }
        
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
        } catch let error {
            print("Failed with error: \(error.localizedDescription)")
            return nil
        }
        
        RLAgent.agents[modelInfo.name] = self
    }
    
    private func tensorToByte(tensor : [[Int]]) -> Data {
        var inputData = Data()
        for row in tensor {
            for element in row {
                var f = Float32(element)
                let elementSize = MemoryLayout.size(ofValue: f)
                var bytes = [UInt8](repeating: 0, count: elementSize)
                memcpy(&bytes, &f, elementSize)
                inputData.append(&bytes, count: elementSize)
            }
        }
        return inputData
    }
    
    private func makeModelPredict(inputData : Data) -> [Float32]? {
        do {
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()
            let output = try interpreter.output(at: 0)

            let results = [UInt8](output.data)
            
            var outputTensor = [Float32]()
            
            for i in stride(from: 0, to: 7, by: 1) {
                let byteArray = Array(results[4*i...4*i+3])
                var f : Float32 = 0
                memcpy(&f, byteArray, 4)
                outputTensor.append(f)
            }
            return outputTensor

        } catch let error {
            print("Failed with error \(error.localizedDescription)")
            return nil
        }
    }
    
    func decideMove(_ game: Game) -> Int {
        let gameStateTensor = convertGameToTensor(game)
        let inputData = tensorToByte(tensor: gameStateTensor)
        let validMoves = getValidMoves(game)
        if Int.random(in: 1 ... 100) < randomness {
            return RandomAgent.decideMove(game, validMoves: validMoves)
        } 
        guard let actions = makeModelPredict(inputData: inputData) else {
            return RandomAgent.decideMove(game, validMoves: validMoves)
        }
        
        let validRewards = zip(actions, actions.indices).filter {
            validMoves.contains($1)
        }

        let bestMove =  validRewards.max { $0.0 < $1.0}!
        return bestMove.1
    }
    
    func isRobot() -> Bool {
        return true
    }
    
    private func convertGameToTensor(_ game: Game) -> [[Int]] {
        var inputTensor : [[Int]] = Array(repeating:
            Array(repeating: 0, count: game.width), count: game.height)
     
        for col in stride(from: 0, to: game.width, by: 1) {
            for row in stride(from: 0, to: game.height, by: 1) {
                if row >= game.board[col].count {
                    break
                } else {
                    let pieceColor = game.board[col][row]
                    inputTensor[game.height - 1 - row][col] = colorToNum(color: pieceColor)
                }
            }
        }
        return inputTensor
    }
}
