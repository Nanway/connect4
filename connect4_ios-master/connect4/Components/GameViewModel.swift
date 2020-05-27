//
//  GameViewModel.swift
//  connect4
//
//  Created by Nanway Chen on 26/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import Foundation

protocol GameViewModelDelegate : class {
    func gameViewModel(player : Color, playedMove : Int)
    func gameViewModelReset()
    func gameViewModel(wonGame : Color)
    func gameViewModelStart()
    func gameViewModelDraw()
}

class GameViewModel {
    private let playerOne : Agent
    private let playerTwo : Agent
    private var currentPlayer : Agent
    private let game : Game
    private var gameReady : Bool = false
    private var delay = 0.5
    var awaitingPlayerMove : Bool
    weak var delegate : GameViewModelDelegate?
    
    var playerTurn : Color {
        return game.playerTurn
    }
    
    var width : Int {
        return game.width
    }
    
    var height : Int {
        return game.height
    }
    
    init(config : [(GameType, Int)]) {
        self.game = Game()
        playerOne = AgentFactory.createAgent(type: config[0], player: .red)
        playerTwo = AgentFactory.createAgent(type: config[1], player: .blu)
        awaitingPlayerMove = !playerOne.isRobot()
        currentPlayer = playerOne
    }
    
    func gameStart() {
        gameReady = true
        delegate?.gameViewModelStart()
        if playerOne.isRobot() && playerTwo.isRobot() {
            delay = 1.0
            decideAndPlay()
        } else if !awaitingPlayerMove {
            decideAndPlay()
        }
    }
    
    func gameReset() {
        game.reset()
        gameReady = false
        currentPlayer = playerOne
        awaitingPlayerMove = !playerOne.isRobot()
        delegate?.gameViewModelReset()
    }
    
    func decideAndPlay() {
        guard gameReady else {
            return
        }

        switch game.gameStatus {
        case .Draw, .Won(_):
            return
        case .OnGoing:
            break
        }
        
        let move = currentPlayer.decideMove(game)
        playMove(move)
    }
    
    @discardableResult
    func playMove(_ move : Int) -> Bool {
        
        let player = game.playerTurn
        game.playMove(col: move)
        delegate?.gameViewModel(player: player, playedMove: move)
        
        switch game.gameStatus {
        case .Draw:
            delegate?.gameViewModelDraw()
        case .Won(let winner):
            delegate?.gameViewModel(wonGame: winner)
        case .OnGoing:
            break
        }

        switchPlayer()
        return true
    }
    
    func switchPlayer() {
        currentPlayer = currentPlayer === playerOne ? playerTwo : playerOne
        if currentPlayer.isRobot() {
            awaitingPlayerMove = false
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.decideAndPlay()
            }
        } else {
            awaitingPlayerMove = true
        }
    }
    
}

class AgentFactory {
    static func createAgent(type : (GameType, Int), player : Color) -> Agent {
        switch type.0 {
        case .AI(let name):
            guard let agent = RLAgent.getAgent(modelName: name ,color: player, randomness: type.1) else {
                return RandomAgent()
            }
            return agent
        case .Human:
            return HumanAgent()
        case .Random:
            return RandomAgent()
        }
    }
}
