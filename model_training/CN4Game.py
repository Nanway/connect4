from enum import Enum
import numpy as np

class Color(Enum):
    RED = 1
    BLUE = 2
    NONE = 0

class Game:
    def __init__(self, width, height, connectX):
        self.board = []
        self._width = width
        self._height = height
        self._connectX = connectX
        self.player_turn = Color.RED
        self.game_won = False
        self.game_over = False
        self._turns = 0

        for i in range(self._width):
            self.board.append([])

    def reset(self):
        self.player_turn = Color.RED
        self.game_won = False
        self.board = [[] for i in range(self._width)]
        self._turns = 0
        self.game_over = False

    def play_move(self, col):
        if (self.game_won):
            return 
        if (not self.check_valid_move(col)):
            print(col)
            self.print_game_state()
            raise Exception("Invalid move played!")
            return
        
        self.board[col].append(self.player_turn)
        self._turns += 1

        if (self.check_game_winner(col)):
            self.game_won = True 
            self.game_over = True
            return

        if (self.check_game_over()):
            self.game_over = True
            return
        
        if (self.player_turn == Color.RED):
            self.player_turn = Color.BLUE
        else:
            self.player_turn = Color.RED

    def check_game_over(self):
        for col in self.board:
            if len(col) < self._height:
                return False
        return True
    
    def check_valid_move(self, col):
        if (col < 0 or col >= self._width):
            return False
        elif (len(self.board[col]) >= self._height):
            return False
        else:
            return True

    def check_game_winner(self, col):
        if len(self.board[col]) <= 0:
            return False
        vert = len(self.board[col]) -1
        color_to_match = self.board[col][-1]

        def horizontal_cond_p(i): return  col + i < self._width and vert < len(self.board[col + i]) and self.board[col + i][vert] == color_to_match
        def horizontal_cond_m(i): return  col - i >= 0 and vert < len(self.board[col - i]) and self.board[col - i][vert] == color_to_match

        def vertical_cond_p(i): return  vert + i < self._height and vert + i < len(self.board[col]) and self.board[col][vert + i] == color_to_match
        def vertical_cond_m(i): return  vert - i >= 0 and vert - i < len(self.board[col]) and self.board[col][vert - i] == color_to_match

        def neDiagPlus(i): 
            return col + i < self._width and vert + i < len(self.board[col + i]) and self.board[col + i][vert + i] == color_to_match
        def neDiagMinus(i): 
            return col - i >= 0 and vert - i < len(self.board[col-i]) and vert - i >= 0 and self.board[col -i][vert-i] == color_to_match
        def nwDiagPlus(i): 
            return col -i >= 0 and vert + i < len(self.board[col - i]) and self.board[col-i][vert + i] == color_to_match
        def nwDiagMinus(i):
            return col + i < self._width and vert - i <len( self.board[col + i]) and vert - i >= 0 and self.board[col + i][vert -i] == color_to_match

        rows = [horizontal_cond_m, horizontal_cond_p]
        cols = [vertical_cond_p, vertical_cond_m]
        diag1 = [neDiagPlus, neDiagMinus]
        diag2 = [nwDiagMinus, nwDiagPlus]

        conds = [rows, cols, diag1, diag2]

        i = 0
        for cond in conds:
            i+=1
            if (self.check_winner(col, vert, cond)):
                return True

        return False 


    def check_winner(self, col, vert, conds):
        num_in_a_row = 1

        for cond in conds:
            for i in range(1, self._connectX):
                if (cond(i)):
                    num_in_a_row += 1
                    if (num_in_a_row == self._connectX): return True 
                else:
                    break
        
        return False

    def get_game_state(self):
        state = np.zeros((self._height, self._width, 1))
        for col in range(0, self._width):
            for row in range(0, self._height):
                if row >= len(self.board[col]):
                    break
                else:
                    enum_to_num = {
                        Color.RED : 1,
                        Color.BLUE : 2, 
                        Color.NONE : 0
                    }

                    state[self._height - 1 - row][col] = enum_to_num[(self.board[col][row])]

        return state


    def print_game_state(self):
        for row in range(self._height -1, -1, -1):
            for col in range(0, self._width):
                if row >= len(self.board[col]):
                    print("?", end=' ')
                else:
                    conversion = {
                        Color.RED : 'r',
                        Color.BLUE : 'b'
                    }
                    print(conversion[self.board[col][row]], end=' ')

            print('\n')