# connect4

To get a grasp of reinforcement learning I decided to train a model to play connect4 against me.

The models trained okay and are able to learn to block connecting 4 in a column. Sometimes they are able to do diagonals and rows, but primarily skew towards columns. The architecture was taken from other ones online. See here for an iOS app that was used to train and play them:

https://github.com/Nanway/connect4_ios

I used double deep Q learning with offline learning (I experimented with how many games before I should replay in memory). The reason I chose double deep Q learning was so to avoid confirmation bias in learning.

In terms of training I tried a variety of strategies:
- I initially played against a player that plays the same move over and over again to see if the model initially learns
- I then train against a completely random player
- I then train against itself
- I then train against a MiniMax agent taken from the internet at various levels
- Then I combined all training strategies 

Trials and tribulations:
- Training takes far too long and I don't have this kind of time. Since the model needs to explore the game state
- I found it hard to quantify how well my model was doing. I had a set of validation game sets to validate the model to see if it chose the right move in the right situation, the best model was able to guess most bar one of these validation games but that didn't mean it was a performant model. 
- I also quantified the models results by seeing how well it performs against a random agent every certain number of training steps. I was able to get up to low 90s but still i feel like the models could perform better. 
- The models were not able to fully generalise that well. The best red player (player one) was able to learn columns lead to winning and losing, but sometimes it gets distracted
- Training against a minimax agent was able to get the model to get better faster. But it learnt how not to lose but didn't learn how to win. Also the minimax agents I took from the internet had bugs and the agent ended up exploiting its bugs to win (lol).
- Training against another bot added a lot of noise to the dataset due to the high probability of random/ ill-informed moves, meaning that the model would reach a point where it could've won but chose another move instead
- Exploration vs Exploitation trade off - randomness in training data vs results that fail to generalise. Wasn't sure how to handle it and the best way of doing it. I annealed the epsilon over time and made it reset after a large amount of games in case it hit a local minima but at the same time I really found it hard to structure and quantify the results since reinforcement learning is a bit different to normal deep learning. 
- I feel like to get better results the model simply just needs to train longer but I didn't have the time nor resources. Overall the best on trained on around 500k games? I could have added minor things to help it train such as noticing when it has a winning opportunity and feeding the model extra data to say that in state X, action Y would have led to a win. But this defeats the whole purpose of reinforcement learning, I want the model to know as little of the game state as it can and want it to figure it out, don't want to give it too much of an idea of how to win. 
- I randomly chose the reward metrics and maybe I could have fine tuned this. 

Biggest learnings/ things I should have done:
- Adding structure to model training process to keep track of architectures and hyperparameters to see which ones performed the best. When I did this I kind of haphazardly chose values and changed them and didn't have a good structure in training models so that I can actually use quantitative evidence to determine which ones were more performant than others
- Adding better metrics and visualisations to the model training to see how they are performing
- Essentially I didn't know how to finetune my models in a reinforcement learning paradigm and I think more structure to the training process might have helped. 

Overall it was a good learning experience and I did create a model that was decent (gives me a bit of trouble trying to beat it after like 2.5 million training games). There is definitely lots of room for improvement (the codebase is a mess as well) and if I have the time/ resources I may train the model for longer. 
- 
