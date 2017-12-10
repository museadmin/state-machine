require 'state/machine'

# TODO Create a user actions dir somewhere outside the gem
USER_ACTIONS = '/Users/atkinsb/RubymineProjects/state-machine/test_actions'

sm = StateMachine.new({user_actions: USER_ACTIONS})
sm.load_actions
sm.execute
