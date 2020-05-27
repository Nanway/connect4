//
//  GameBoard.swift
//  connect4
//
//  Created by Nanway Chen on 9/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import Foundation

enum GameState {
    case Won(Color)
    case Draw
    case OnGoing
}

enum Color : String {
    case red = "Red"
    case blu = "Yellow"
}

public class Game {
    var board : [[Color]]
    var width = 7
    var height = 6
    var connectX = 4
    var playerTurn = Color.red
    var gameStatus = GameState.OnGoing
    
    init() {
        board = Array(repeating: [], count: width)
    }
    
    func reset() {
        playerTurn = Color.red
        gameStatus = GameState.OnGoing
        board = Array(repeating: [], count: width)
    }
    
    func playMove(col: Int) {
        // check if valid
        if (!checkValidMove(col)) {
            return
        }
        
        // make move
        board[col].append(playerTurn)
        checkGameOver(col)
        
        // check game winner
        switch gameStatus {
        case .Draw:
            return
        case .Won( _):
            return
        case .OnGoing: break
        }
        
        // switch colours
        if (playerTurn == Color.red) {
            playerTurn = Color.blu
        } else {
            playerTurn = Color.red
        }
    }
    
    func checkGameOver(_ col: Int) {
        if checkGameWinner(col) {
            gameStatus = .Won(playerTurn)
            return
        }
        
        for column in board {
            if column.count < height {
                gameStatus = .OnGoing
                return
            }
        }
        
        gameStatus = .Draw
    }
    
    func checkGameWinner(_ col: Int) -> Bool {
        
        let vert = board[col].count - 1
        guard vert >= 0 else {
            return false
        }
        let newest = board[col][vert]
        
        let horizontalCondAdd = {(i: Int) -> Bool in
            return col + i < self.width && vert < self.board[col + i].count && self.board[col + i][vert] == newest
        }
        
        let horizontalCondMinus = {(i: Int) -> Bool in
            return col - i >= 0 && vert < self.board[col - i].count && self.board[col - i][vert] == newest
        }
        
        let verticalCondPlus =  {(i : Int) -> Bool in
            return vert + i < self.height  && vert + i < self.board[col].count &&  self.board[col][vert + i] == newest
        }
        
        let verticalCondMinus = {(i : Int) -> Bool in
            return vert - i >= 0 && vert - i < self.board[col].count && self.board[col][vert - i] == newest
        }
        
        let neDiagPlus = {(i : Int) -> Bool in
            return col + i < self.width && vert + i < self.board[col + i].count && self.board[col + i][vert + i] == newest
        }
        
        let neDiagMinus = {(i : Int) -> Bool in
            return col - i >= 0 && vert - i < self.board[col - i].count && vert - i >= 0 && self.board[col - i][vert - i] == newest
        }
        
        let nwDiagPlus = {(i : Int) -> Bool in
            return col - i >= 0 && vert + i < self.board[col - i].count && self.board[col - i][vert + i] == newest
        }
        let newDiagMinus = {(i : Int) -> Bool in
            return col + i < self.width && vert - i < self.board[col + i].count && vert - i >= 0 && self.board[col + i][vert - i] == newest
        }
        
        let checkRow = [horizontalCondAdd, horizontalCondMinus]
        let checkCol = [verticalCondPlus, verticalCondMinus]
        let checkDiag1 = [neDiagPlus, neDiagMinus]
        let checkDiag2 = [nwDiagPlus, newDiagMinus]
        let conds = [checkRow, checkCol, checkDiag1, checkDiag2]
        
        for cond in conds {
            if checkWinner(col: col, vert: vert, checkConds: cond) {
                return true
            }
        }

        return false
    }
    
    func checkValidMove(_ col: Int) -> Bool {
        if (col < 0 || col >= width) {
            return false
        } else if (board[col].count >= height) {
            return false
        } else {
            return true
        }
    }
    
    func printBoardState() {
        for row in stride(from: height - 1, through: 0, by: -1) {
            for col in 0 ... width - 1 {
                if (row < board[col].count) {
                    print(board[col][row], terminator: " ")
                } else {
                    print("xxx", terminator: " ")
                }
            }
            print("\n")
        }
    }
    
    // 1 for up/ down
    // o for left right
    private func checkWinner(col: Int, vert: Int, checkConds: [(Int) -> Bool]) -> Bool {
        var  numInRow = 1

        for cond in checkConds {
            for i in (1 ... connectX) {
                if (cond(i)) {
                    numInRow += 1
                    if (numInRow == connectX) {
                        return true
                    }
                } else {
                    break
                }
            }
        }
        return false
    }
}
