from tensorflow.keras.layers import Conv2D, LeakyReLU, Flatten, Dense
from tensorflow.keras.optimizers import Adam
from tensorflow.keras import Sequential
from tensorflow.keras.models import load_model
import numpy as np

class Brain:
    def __init__(self, rows: int, cols: int, model_path: str =None, lr=0.0001):
        if (model_path is None):
            self.model_path = 'bigbrain.h5'
            self.model = self.create_model(rows, cols, lr)
            self.target_model = self.create_model(rows, cols, lr)
        else:
            self.model_path = model_path
            try:
                self.model = load_model(model_path)
                self.target_model = load_model(model_path)
            except:
                self.model = self.create_model(rows, cols, lr)
                self.target_model = self.create_model(rows, cols, lr)

        self.model.summary()

    def update_target(self):
        self.target_model.set_weights(self.model.get_weights())

    def create_model(self, rows, cols, lr):
        model = Sequential()
        model.add(Conv2D(20, (4, 4), padding='same', input_shape=(rows, cols, 1)))
        model.add(LeakyReLU(alpha=0.3))
        model.add(Conv2D(20, (4, 4), padding='same'))
        model.add(LeakyReLU(alpha=0.3))
        model.add(Conv2D(30, (4, 4), padding='same'))
        model.add(LeakyReLU(alpha=0.3))
        model.add(Conv2D(30, (4, 4), padding='same'))
        model.add(LeakyReLU(alpha=0.3))
        model.add(Conv2D(30, (4, 4), padding='same'))
        model.add(LeakyReLU(alpha=0.3))
        model.add(Flatten())
        model.add(Dense(49))
        model.add(LeakyReLU(alpha=0.3))
        model.add(Dense(7))
        model.add(LeakyReLU(alpha=0.3))
        model.add(Dense(cols, activation='linear'))
        model.compile(optimizer=Adam(lr=lr), loss='mean_squared_error', metrics=['accuracy'])
        return model

    def train(self, x, y, bs, epochs=5):
        self.model.fit(x,y, batch_size=bs, epochs=epochs)
        self.model.save(self.model_path)

    def validate(self, x):
        actions = []
        for state in x:
            action = self.model.predict_one(state)
            actions.append(action)
        return actions

    def predict(self, state, target=False):
        return np.squeeze(self.model.predict(state))

    def predict_one(self, state, target=False):
        if (len(state.shape) == 2):
            state = np.expand_dims(state, axis=0)
            state = np.expand_dims(state, axis=3)
        elif (len(state.shape) == 3):
            if (state.shape[0] != 1):
                state = np.expand_dims(state, axis=0)
            else:
                state = np.expand_dims(state, axis=3)

        return self.predict(state, target)