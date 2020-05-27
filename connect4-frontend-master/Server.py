from flask import Flask, request, jsonify, send_from_directory, render_template
from flask_cors import CORS
from tensorflow.keras.models import load_model
import numpy as np
import os

app = Flask(__name__, static_folder='./build')
CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'
player_one = load_model('red_brain_ddqn_fat.h5')
player_two = load_model('blu_brain_ddqn_fat.h5')
print("Both players loaded succesfully")


print(os.listdir())
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve(path):
    print("Tryna serve some stuff")
    if path != "" and os.path.exists(app.static_folder + '/' + path):
        return send_from_directory(app.static_folder, path)
    else:
        return send_from_directory(app.static_folder, 'index.html')

# Expects a JSON with
#   Board - current board state : 6 x 7 array with row index 0 as bottom row of the game
#   Player - player to get prediction for : either 1 or 2 
@app.route('/api/predict', methods=['POST'])
def predict():
    req = request.get_json()
    board = req['board']
    player = req['player']

    # convert board into a form we want
    new_board = []
    for row in board:
        new_row = [0 if x is None else x for x in row]
        new_board.append(new_row)

    model = player_one if player == 1 else player_two
    new_board = np.asarray(new_board)
    new_board = np.expand_dims(new_board, axis = 0)
    new_board = np.expand_dims(new_board, axis = 3)
    return jsonify(np.squeeze(model.predict(new_board)).tolist())




port = int(os.environ.get("PORT", 5000))
app.run(debug=False, host='0.0.0.0', port=port)