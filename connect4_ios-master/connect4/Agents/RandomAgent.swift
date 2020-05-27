//
//  RandomAgent.swift
//  connect4
//
//  Created by Nanway Chen on 26/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import Foundation

final class RandomAgent : Agent {
    static func decideMove(_ game: Game, validMoves : [Int]) -> Int {
        let moveInd = Int.random(in: 0..<validMoves.count)
        return validMoves[moveInd]
    }
    
    func decideMove(_ game: Game) -> Int {
        let validMoves = getValidMoves(game)
        return RandomAgent.decideMove(game, validMoves: validMoves)
    }
    
    func isRobot() -> Bool {
        return true
    }
}
