from tensorflow.keras.models import load_model
from Agent import *
import numpy as np

class GiladrielAgent(Agent):
    def __init__(self):
        self.model = load_model('model_values_second.h5')

    def observe(self, sample):
        pass

    def shouldValidate(self):
        return False

    def replay(self, end_rewards):
        pass

    def act(self, state, game):
        state = np.squeeze(state)
        for x in range(len(state)):
            for y in range(len(state[x])):
                if (state[x][y] == 2):
                    state[x][y] = -1

        moves = np.where(state[0, :] == 0)[0]
        move = self.choose_optimal_move(state, moves)
        return move
        # convert into 1 and - 1

        # add 

    def choose_optimal_move(self, state, moves):
        v = -float('Inf')
        v_list = []
        idx = []

        for move in moves:
            predict_on = self.state_to_tensor(state, move)
            value = self.model.predict(predict_on)
            v_list.append(round(float(value), 5))

            if value > v:
                v = value
                idx = [move]
            elif v == value:
                idx.append(move)

        idx = random.choice(idx)
        return idx

    def state_to_tensor(self, state, move):

        vec = np.zeros((1, 7))
        if move != -1:
            vec[0, move] = 1
        tensor = np.append(vec, state, axis=0)
        tensor = tensor.reshape((1, 7, 7, 1))

        return tensor