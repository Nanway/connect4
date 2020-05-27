import React from 'react';
import ToggleButtonGroup from 'react-bootstrap/ToggleButtonGroup'
import ToggleButton from 'react-bootstrap/ToggleButton'
import ButtonToolBar from 'react-bootstrap/ButtonToolbar'
import Container from 'react-bootstrap/Container'
import Row from 'react-bootstrap/Row'
import Col from 'react-bootstrap/Col'

class PlayerPicker extends React.Component {
  render() {
    return (
      <div>
        <Container>
          <Row className="align-items-center">
            <Col align="center"> Player One:  </Col>
            <Col align="center"> <PlayerTypePicker name={"Player 1 picker"} onChange={(val) => {this.props.onSelectPlayerType(this.props.player1, val)}}/> </Col>
          </Row>
          <br></br>
          <Row className="align-items-center">
            <Col align="center"> Player Two: </Col>
            <Col align="center"> <PlayerTypePicker name={"Player 2 picker"} onChange={(val) => {this.props.onSelectPlayerType(this.props.player2, val)}}/> </Col>
          </Row>
          <br></br>
        </Container>
      </div>
    );
  }
}


function PlayerTypePicker(props) {
  return (
    <ButtonToolBar>
      <ToggleButtonGroup type="radio" name={props.name} defaultValue={false} onChange={props.onChange}>
        <ToggleButton value={false}>Human</ToggleButton>
        <ToggleButton value={true}>AI</ToggleButton>
      </ToggleButtonGroup>
    </ButtonToolBar>

  );
}

export default PlayerPicker;