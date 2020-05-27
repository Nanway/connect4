import React from 'react';
import ReactRow from 'react-bootstrap/Row'
import './App.css';
import axios from 'axios';

const CancelToken = axios.CancelToken;
const source = CancelToken.source();

class Board extends React.Component {
    constructor(props) {
      super(props);
      
      this.state = {
        player1: 1,
        player2: 2,
        currentPlayer: null,
        board: [],
        gameOver: false,
        message: <ReactRow><div className={"red"}></div></ReactRow>,
        ai : {1 : this.props.player1, 2 : this.props.player2}
      };

      // Bind play function to App component
      this.onClickBoard = this.onClickBoard.bind(this);
    }
    
    // Starts new game
    initBoard() {
      // Create a blank 6x7 matrix
      let board = [];
      for (let r = 0; r < 6; r++) {
        let row = [];
        for (let c = 0; c < 7; c++) { row.push(null) }
        board.push(row);
      }
      
      let onSetState = () => {
        if (this.state.ai[this.state.currentPlayer]) {
          this.decideMove().then((val) => {
            this.play(val)
          })
        }
      }

      this.setState({
        board,
        currentPlayer: this.state.player1,
        gameOver: false,
        message: <ReactRow><div className={"red"}></div></ReactRow>,
      }, onSetState);
    }
    
    togglePlayer() {
      return (this.state.currentPlayer === this.state.player1) ? this.state.player2 : this.state.player1;
    }

    async decideMove() {
      try {
        const response = await axios.post(
          window.location.href + 'api/predict',
          { board: this.state.board,
            player: this.state.currentPlayer },
          { headers: { 'Content-Type': 'application/json' }},
          {cancelToken : source.cancelToken}
        )
  
  
        let validMoves = []
        response.data.map((x, index) => {
          if (this.validMove(index)) {
            validMoves.push({ move: index, score: x})
          }
        })
  
        let bestOutcome = null
        for (let i = 0 ; i < validMoves.length; i ++) {
          if (bestOutcome === null) {
            bestOutcome = validMoves[i]
          } else if (validMoves[i].score >= bestOutcome.score) {
            bestOutcome = validMoves[i]
          }
        }
  
        return bestOutcome.move
      } catch(error) {
        console.log("error", error)
        alert("Server is down! Try again later")
        return
      }
    }
    
    onClickBoard(index) {
      if (!this.state.ai[this.state.currentPlayer]) {
        this.play(index)
      }
    }

    async play(c) {
      if (!this.validMove(c)) {
        return
      }

      if (!this.state.gameOver) {
        // Place piece on board
        let board = this.state.board;
        for (let r = 5; r >= 0; r--) {
          if (!board[r][c]) {
            board[r][c] = this.state.currentPlayer;
            break;
          }
        }
  
        // Check status of board
        let result = this.checkAll(board);
        if (result === this.state.player1) {
          this.setState({ board, gameOver: true, message: <ReactRow><div className={"red"}></div></ReactRow>});
        } else if (result === this.state.player2) {
          this.setState({ board, gameOver: true, message: <ReactRow><div  className={"yellow"}></div></ReactRow>});
        } else if (result === 'draw') {
          this.setState({ board, gameOver: true, message: 'Draw game.' });
        } else {
          var message = ""
          if (this.state.currentPlayer === this.state.player1) {
            message = <div className={"yellow"}></div>
          } else {
            message = <div className={"red"}></div>
          }
          await this.setState({ board, currentPlayer: this.togglePlayer(), message: message});
          if (this.state.ai[this.state.currentPlayer]) {
            let move = await this.decideMove()
            await this.timeout(1500)
            this.play(move)
          }
        }
      } else {
        this.setState({ message: 'Game over. Please start a new game.' });
      }
    }

    timeout(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
  }

    validMove(move) {
      if (move < 0 || move > 6) {
        return false 
      } else if (this.state.board[0][move] === null) {
        return true
      }
      return false
    }
    
    checkVertical(board) {
      // Check only if row is 3 or greater
      for (let r = 3; r < 6; r++) {
        for (let c = 0; c < 7; c++) {
          if (board[r][c]) {
            if (board[r][c] === board[r - 1][c] &&
                board[r][c] === board[r - 2][c] &&
                board[r][c] === board[r - 3][c]) {
              return board[r][c];    
            }
          }
        }
      }
    }
    
    checkHorizontal(board) {
      // Check only if column is 3 or less
      for (let r = 0; r < 6; r++) {
        for (let c = 0; c < 4; c++) {
          if (board[r][c]) {
            if (board[r][c] === board[r][c + 1] && 
                board[r][c] === board[r][c + 2] &&
                board[r][c] === board[r][c + 3]) {
              return board[r][c];
            }
          }
        }
      }
    }
    
    checkDiagonalRight(board) {
      // Check only if row is 3 or greater AND column is 3 or less
      for (let r = 3; r < 6; r++) {
        for (let c = 0; c < 4; c++) {
          if (board[r][c]) {
            if (board[r][c] === board[r - 1][c + 1] &&
                board[r][c] === board[r - 2][c + 2] &&
                board[r][c] === board[r - 3][c + 3]) {
              return board[r][c];
            }
          }
        }
      }
    }
    
    checkDiagonalLeft(board) {
      // Check only if row is 3 or greater AND column is 3 or greater
      for (let r = 3; r < 6; r++) {
        for (let c = 3; c < 7; c++) {
          if (board[r][c]) {
            if (board[r][c] === board[r - 1][c - 1] &&
                board[r][c] === board[r - 2][c - 2] &&
                board[r][c] === board[r - 3][c - 3]) {
              return board[r][c];
            }
          }
        }
      }
    }
    
    checkDraw(board) {
      for (let r = 0; r < 6; r++) {
        for (let c = 0; c < 7; c++) {
          if (board[r][c] === null) {
            return null;
          }
        }
      }
      return 'draw';    
    }
    
    checkAll(board) {
      return this.checkVertical(board) || this.checkDiagonalRight(board) || this.checkDiagonalLeft(board) || this.checkHorizontal(board) || this.checkDraw(board);
    }
    
    componentDidMount() {
      this.initBoard();
    }

    componentWillUnmount() {
      source.cancel("fuggen send it")
    }
    
    render() {
      return (
        <div>
          <div style={{textAlign : "center"}}>
            {this.state.message}
            {this.state.gameOver && this.state.message != "Draw game." &&
              <h2>Winner!</h2>
            } 
          </div>
          <br></br>
          <table>
            <thead>
            </thead>
            <tbody>
              {this.state.board.map((row, i) => (<Row key={i} row={row} onClickBoard={this.onClickBoard} />))}
            </tbody>
          </table>
          <br></br>
          <div style={{textAlign : "center"}}>
            <button className="icon" onClick={this.props.onBack}><i className="fa fa-arrow-left"></i></button>
            <button className="icon red-sm" onClick={() => {this.initBoard()}}><i className="fa fa-refresh"></i></button>
          </div>
        </div>
      );
    }
  }
  
export default Board;

// Row component
const Row = ({ row, onClickBoard }) => {
    return (
        <tr>
        {row.map((cell, i) => <Cell key={i} value={cell} columnIndex={i} onClickBoard={onClickBoard} />)}
        </tr>
    );
};

const Cell = ({ value, columnIndex, onClickBoard}) => {
    let color = 'white';
    if (value === 1) {
        color = 'red';
    } else if (value === 2) {
        color = 'yellow';
    }
    
    return (
        <td>
        <div className="cell" onClick={() => {onClickBoard(columnIndex)}}>
            <div className={color}></div>
        </div>
        </td>
    );
};