require 'state/state_machine'

# TODO Create a user actions dir somewhere outside the gem
USER_ACTIONS = '/Users/atkinsb/RubymineProjects/state-machine/test/test_actions'
DB_FILE = '/Users/atkinsb/RubymineProjects/state-machine-dev/database/state-machine.db'

options = {
    user_actions_dir: USER_ACTIONS,
    sqlite3_db: DB_FILE
}
sm = StateMachine.new(options)
sm.create_db
sm.load_actions
sm.execute
