from Memory import Memory
import math
import numpy as np
import random

class Agent:
    def __init__(self, brain, capacity, min_e, max_e, decay, alpha, gamma, bs, train_size, num_act, tuf=5, td=0.5):
        self.brain = brain
        self.memory = Memory(capacity)
        self.epsilon = max_e
        self.decay = decay
        self.min_e = min_e
        self.max_e = max_e
        self.alpha = alpha
        self.gamma = gamma
        self.num_act = num_act
        self.steps = 0
        self.bs = bs
        self.target_update_frequency = tuf
        self.num_times_train = 0
        self.temp_mem = []
        self.td = td
        self.train_size = train_size

    def observe(self, sample):
        s, a, r, s_ = sample

        if (s is None):
            s = np.zeros(s_.shape)
        elif (s_ is None):
            s_ = np.zeros(s.shape)

        self.steps += 1
        self.epsilon = self.min_e + (self.max_e - self.min_e) * math.exp(-self.decay * self.steps)
        self.temp_mem.append((s, a, r, s_))

        if (r!=0):
            n = len(self.temp_mem) - 1
            for tmp_sample in self.temp_mem:
                s_t, a_t, r_t, s_t_ = tmp_sample
                r_t = r*(self.td**n)
                if (n == 0):
                    self.memory.add((s_t, a_t, r_t, s_t_, True))
                else:
                    self.memory.add((s_t, a_t, r_t, s_t_, False))
                n -= 1
            self.temp_mem = []

    def replay(self, end_rewards):
        batch = self.memory.sample(self.train_size)

        self.num_times_train += 1
        #batch = self.memory.samples
        if (self.num_times_train % self.target_update_frequency == 0):
            self.brain.update_target()

        # generate Q value
        states = np.array([item[0] for item in batch])
        states_ = np.array([item[3] for item in batch])
        predictions = self.brain.predict(states)
        future_predictions = self.brain.predict(states_)
        target_predictions = self.brain.predict(states_, target=True)

        # create x and y
        x = states
        y = []
        for sample, pred, pred_, pred_targ in zip(batch, predictions, future_predictions, target_predictions):
            _, a, r, s_, end = sample
            target_actions = pred
            # for end game sample 
            if (end):
                if (r == 75):
                    target_actions[:] = 0
                    target_actions[a] = r
                else:
                    target_actions[a] = r
                y.append(target_actions)
            else:
                q = target_actions[a]
                a_next = np.argmax(pred_)
                target_actions[a] = q + self.alpha*(r + self.gamma*pred_targ[a_next] - q)
                y.append(target_actions)
        self.brain.train(x,np.array(y), self.bs)

    def shouldValidate(self):
        return True

    def act(self, state, game):
        invalid_moves = []
        moves = []
        for move in range(self.num_act):
            moves.append(move)
            if not game.check_valid_move(move):
                invalid_moves.append(move)

        allowable_moves = list(set(moves) - set(invalid_moves))
        if random.random() < self.epsilon:
            random_move = random.randint(0, len(allowable_moves) -1)
            return allowable_moves[random_move]
        else:
            # get predictions
            # filter out the non allowables ones
            # take the max
            predicted_actions = self.brain.predict_one(state)
            predicted_actions[np.array(invalid_moves, int)] = np.amin(predicted_actions) - 100
            if (not game.check_valid_move(np.argmax(predicted_actions))):
                print(predicted_actions)
                game.print_game_state()

            return np.argmax(predicted_actions)

'''
    def _random_helper(self):
        if (r!= 0):

            for row in np.squeeze(s):
                for elem in row:
                    print(elem, end = ' ')
                print('\n')
            print("Then")
            if (s_ is not None):
                for row in np.squeeze(s_):
                    for elem in row:
                        print(elem, end = ' ')
                    print('\n')
'''