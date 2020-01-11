from CN4Game import *
from Agent import *
from Brain import *
from Memory import *
from MiniMax import *
from Gilad import *

class Environment:
    # reward scheme: 100 for win, -100 for loss, 50 for draw
    WIN_R = 1
    DRAW_R = 0.5
    LOSE_R = -1

    def __init__(self):
        self.game = Game(7,6,4)
        self.num_games = 0
        self.num_red_wins = 0
        self.num_blue_wins = 0


    def run(self, agent_red, agent_blue, random_agent, mini_max=None):
        self.red_man = agent_red
        self.blue_man = agent_blue
        self.curr_agent = agent_red
        self.random_agent = random_agent

        while True:
            if (self.num_games == 2000):
                self.blue_man = mini_max
            elif (self.num_games == 10000):
                break
            self.curr_agent = self.red_man
            print("Starting game number {}".format(self.num_games + 1))
            self.game.reset()
            self.run_game()

            #if (DEBUG_MODE):
            print("Final game state")
            self.game.print_game_state()

            print("Game ended with {} turns. Red wins: {}. Blue wins: {}. Epsilon: {}".format(self.game._turns, self.num_red_wins, self.num_blue_wins, self.red_man.epsilon))
            if (self.num_games % NUM_GAMES_TILL_REPLAY == 0):
                end_rewards = [self.WIN_R, self.LOSE_R, self.DRAW_R]
                print("Training agent. Num red wins {}. Num blue wins {}".format(self.num_red_wins, self.num_blue_wins))

                if (self.red_man.shouldValidate()):
                    self.red_man.replay(end_rewards)
                    print("Validating red man")
                    self.validate(self.red_man)


                if (self.blue_man.shouldValidate()):
                    # should first check if playing against some random network gives victories
                    self.blue_man.replay(end_rewards)
                    print("Validating blue man")
                    self.validate(self.blue_man)


            # reset randomness every now and again to force exploration
            if (self.num_games % NUM_GAMES_TO_RERANDOM == 0):
                print("Playing red against random agent")
                if (self.red_man.shouldValidate()):
                    self.play_against_random(self.red_man)

                print("Playing blue against random agent")
                if self.blue_man.shouldValidate():
                    self.play_against_random(self.blue_man)

            if (DEBUG_MODE):
                break

    def play_against_random(self, agent):
        if (agent == self.blue_man):
            self.curr_agent = self.random_agent
        else:
            self.curr_agent = agent
        agent.epsilon = 0
        games_played = 0
        num_wins = 0

        while (games_played < 100):
            self.game.reset()
            while (not self.game.game_over):
                action = self.curr_agent.act(self.game.get_game_state(), self.game)
                self.step(action)
                self.curr_agent = agent if self.curr_agent == self.random_agent else self.random_agent
            games_played += 1
            if (self.curr_agent == self.random_agent):
                num_wins += 1
        self.game.print_game_state()
        print("Won {} many times".format(num_wins))


    def run_game(self):
        previous_state = None
        previous_action = None
        self.rewards = {}
        while (not self.game.game_over):
            # make prediction

            if (DEBUG_MODE):
                print("Game state now looks like")
                self.game.print_game_state()


            start_turn_state = self.game.get_game_state()
            action = self.curr_agent.act(start_turn_state, self.game)

            # step
            after_turn_state = self.step(action)
            # If game is over, give rewards to the players otherwise observe for the prev player
            if (self.game.game_over):
                self.give_rewards()

            self.switch_player()
            if (previous_state is not None):
                self.curr_agent.observe((previous_state, previous_action, self.rewards.get(self.curr_agent, 0), after_turn_state))
            previous_state = start_turn_state
            previous_action = action

        self.switch_player()
        self.curr_agent.observe((previous_state, previous_action, self.rewards.get(self.curr_agent, 0), None))

    def give_rewards(self):
        self.num_games += 1
        if (self.game.game_won):
            if (self.curr_agent is self.red_man):
                self.num_red_wins += 1
            else:
                self.num_blue_wins += 1
            # Give reward to current agent who won, switch to loser and give em the L
            self.rewards[self.curr_agent] = self.WIN_R
            self.switch_player()
            self.rewards[self.curr_agent] = self.LOSE_R
        else:
            self.rewards[self.curr_agent] = self.DRAW_R
            self.switch_player()
            self.rewards[self.curr_agent] = self.DRAW_R
        # switch back
        self.switch_player()
    
    def switch_player(self):
        self.curr_agent = self.red_man if self.curr_agent is not self.red_man else self.blue_man

    def step(self, action):
        self.game.play_move(action)
        return self.game.get_game_state()

    def validate(self, agent):
        states, target_moves = self.get_validation_data(agent)
        validation_states = "win_col win_row win_diag1 win_diag2 lose_col lose_row lose_diag1 lose_diag2".split(sep=' ')
        correct = 0
        incorrect = 0
        for state, move, validation_state in zip(states, target_moves, validation_states):
            
            predicted_actions = agent.brain.predict_one(state)
            print(predicted_actions)
            choose = np.argmax(predicted_actions)
            if (choose == move):
                print("{} chose a good move".format(validation_state))
            else:
                print("{} chose {} isntead of {}".format(validation_state, choose, move))
        
    def get_validation_data(self, agent):
        target_moves = []
        if agent is self.red_man:
            win_col = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [1, 0, 0, 0, 0, 0 , 0],
                [1, 2, 0, 0, 0, 0 , 0],
                [1, 2, 2, 0, 0, 0 , 0]
                ], float)
            target_moves.append(0)
            win_row = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [2, 2, 2, 0, 0, 0 , 0],
                [1, 1, 1, 0, 0, 0 , 0]
                ], float)
            target_moves.append(3)
            win_diag1 = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 1, 2, 0, 0 , 0],
                [2, 1, 2, 2, 0, 0 , 0],
                [1, 1, 1, 2, 0, 0 , 0]
                ], float)
            target_moves.append(3)
            win_diag2 = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [2, 1, 1, 2, 0, 0 , 0],
                [2, 2, 1, 2, 0, 0 , 0],
                [1, 1, 2, 1, 0, 0 , 0]
                ], float)
            target_moves.append(0)
            lose_col = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 2, 0, 0, 0, 0 , 0],
                [1, 2, 1, 0, 0, 0 , 0],
                [1, 2, 1, 0, 2, 0 , 0]
                ], float)
            target_moves.append(1)
            lose_row = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 1, 0, 0, 0 , 0],
                [2, 2, 2, 0, 0, 0 , 0],
                [1, 2, 1, 1, 0, 0 , 0]
                ], float)
            target_moves.append(3)
            lose_diag1 = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 1, 2, 2, 2, 0 , 0],
                [0, 1, 2, 2, 1, 0 , 0],
                [1, 2, 1, 2, 1, 0 , 1]
                ], float)
            target_moves.append(4)
            lose_diag2 = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [1, 2, 0, 1, 0, 0 , 0],
                [2, 1, 2, 2, 0, 0 , 0],
                [1, 1, 1, 2, 2, 0 , 0]
                ], float)
            target_moves.append(0)
        else:
            win_col = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 2, 0, 0, 0, 0 , 0],
                [1, 2, 1, 0, 0, 0 , 0],
                [1, 2, 1, 0, 0, 0 , 0]
                ], float)
            target_moves.append(1)
            win_row = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [1, 0, 1, 0, 0, 0 , 0],
                [2, 2, 2, 0, 0, 0 , 0],
                [1, 2, 1, 1, 0, 0 , 0]
                ], float)
            target_moves.append(3)
            win_diag1 = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 1, 0, 2, 1, 0 , 0],
                [0, 1, 2, 1, 2, 0 , 0],
                [0, 2, 1, 2, 1, 0 , 0]
                ], float)
            target_moves.append(3)
            win_diag2 = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [1, 2, 0, 1, 0, 0 , 0],
                [2, 1, 2, 2, 0, 0 , 0],
                [1, 1, 1, 2, 0, 0 , 0]
                ], float)
            target_moves.append(0)
            lose_col = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [1, 0, 0, 0, 0, 0 , 0],
                [1, 2, 2, 0, 0, 0 , 0],
                [1, 2, 1, 0, 0, 0 , 0]
                ], float)
            target_moves.append(0)
            lose_row = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 1, 0, 0, 0 , 0],
                [2, 2, 2, 0, 0, 0 , 0],
                [1, 1, 1, 0, 0, 0 , 0]
                ], float)
            target_moves.append(3)
            lose_diag1 = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 1, 1, 0, 0 , 0],
                [2, 1, 2, 2, 0, 0 , 0],
                [1, 1, 1, 2, 2, 0 , 0]
                ], float)
            target_moves.append(3)
            lose_diag2 = np.array(
                [
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [0, 0, 0, 0, 0, 0 , 0],
                [2, 1, 1, 2, 0, 0 , 0],
                [2, 2, 1, 2, 0, 0 , 0],
                [1, 1, 2, 1, 0, 0 , 1]
                ], float)
            target_moves.append(0)
        states = [win_col, win_row, win_diag1, win_diag2, lose_col, lose_row, lose_diag1, lose_diag2]

        return states, target_moves

if __name__ == "__main__":
    LAMBDA = 0.000008
    MEMORY_SIZE = 100000
    TRAINING_SIZE = 75000
    EXPERIENCE_BS = 300
    DEBUG_MODE = False
    if (DEBUG_MODE):
        MAX_E = 0
        MIN_E = 0
        NUM_GAMES_TO_RERANDOM = 1
    else:
        MAX_E = 0.15
        MIN_E = 0.1
        NUM_GAMES_TO_RERANDOM = 1000

    GAMMA = 0.85
    ALPHA = 0.2
    LR = 0.0003
    ROWS = 6
    COLS = 7
    NUM_GAMES_TILL_REPLAY = 150

    big_brain = Brain(6,7, model_path='red_brain_ddqn_fat.h5')
    small_brain = Brain(6,7, model_path='blu_brain_ddqn_4.h5')
    red_agent = Agent(big_brain, MEMORY_SIZE, MIN_E, MAX_E, LAMBDA, ALPHA, GAMMA, EXPERIENCE_BS, TRAINING_SIZE,  COLS)
    blue_agent = Agent(small_brain, MEMORY_SIZE, MIN_E, MAX_E, LAMBDA, ALPHA, GAMMA, EXPERIENCE_BS, TRAINING_SIZE, COLS)
    random_agent = Agent(None, 0, 1, 1, 0, 0, 0 , 0, 0, COLS)
    random_agent.shouldValidate = lambda : False
    mini_max = Minimax(2)
    gilad = GiladrielAgent()
    env = Environment()
    env.run(red_agent, gilad, random_agent, mini_max=mini_max)