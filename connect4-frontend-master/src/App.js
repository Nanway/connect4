import React from 'react';
import PlayerPicker from './PlayerPicker'
import Button from 'react-bootstrap/Button'
import Row from 'react-bootstrap/Row'
import Col from 'react-bootstrap/Col'
import Board from './Board'
import Navbar from 'react-bootstrap/Navbar'
import Nav from 'react-bootstrap/Nav'
import logo from "./logo.svg"
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';
import Container from 'react-bootstrap/Container';

class App extends React.Component {
  constructor(props) {
    super(props);
    
    this.player1 = "player1";
    this.player2 = "player2";


    this.state = {
      player1: false,
      player2: false,
      gameStart: false
    };

    this.onSelectPlayerType = this.onSelectPlayerType.bind(this)
    this.onBack = this.onBack.bind(this)
  }

  onBack() {
    this.setState({gameStart : false, player1: false, player2: false})
  }

  onSelectPlayerType(player ,val) {
    let newState = this.state
    newState[player] = val
    this.setState(newState)
  }

  startGame() {
    this.setState({gameStart : true})
  }

  decideScreenToRender() {
    if (this.state.gameStart) {
      return (<Board player1={this.state.player1} player2={this.state.player2} onBack={this.onBack}></Board>)
    } else {
      return (
        <Container max-width="100px">
          <Row>
            <Col>
              <PlayerPicker player1={this.player1} player2={this.player2} onSelectPlayerType={this.onSelectPlayerType}></PlayerPicker>
            </Col>
          </Row>
          <Row>
            <Col align="center">
              <Button variant="primary" onClick={() => {this.startGame()}}>Start Game</Button>
            </Col>
          </Row>
        </Container>
      );
    }
  }

  render() {
    return (
    <React.Fragment>

<Navbar bg="primary" variant="dark">
        <Navbar.Brand>
          <img
            src={logo}
            width="30"
            height="30"
            className="d-inline-block align-top"
            alt="Connect 4 RL"
            style={{marginRight: '10px'}}
          />
          Connect 4 RL
        </Navbar.Brand>
        <Navbar.Collapse id="responsive-navbar-nav">
          <Nav className="mr-auto">
          </Nav>
          <Nav>
            <Nav.Link href="https://github.com/Nanway/connect4">My GitHub</Nav.Link>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <br></br>
      <Container>
        {this.decideScreenToRender()}
      </Container>
    </React.Fragment>
  )}
}

export default App;