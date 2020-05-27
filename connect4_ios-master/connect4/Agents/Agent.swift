//
//  Agent.swift
//  connect4
//
//  Created by Nanway Chen on 26/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import Foundation

protocol Agent : class {
    func decideMove(_ game : Game) -> Int
    func isRobot() -> Bool
    func getValidMoves(_ game : Game) -> [Int]
}

extension Agent {
    func getValidMoves(_ game : Game) -> [Int] {
        var validMoves : [Int] = []
        
        for move in 0 ..< game.width {
            if game.checkValidMove(move) {
                validMoves.append(move)
            }
        }
        return validMoves
    }
}

final class HumanAgent : Agent {
    func decideMove(_ game: Game) -> Int {
        return -1
    }
    
    func isRobot() -> Bool {
        return false
    }
}
