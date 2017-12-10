require 'state/machine'

user_actions = '/Users/atkinsb/RubymineProjects/state-machine/test_actions'

sm = StateMachine.new(user_actions)
# sm.test_actions = test_actions
sm.load_actions
sm.execute
