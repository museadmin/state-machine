require 'state/machine/version'
require 'state/required_actions'
require 'state/support/action_loader'
require 'state/support/action_support'
require 'state/support/data_access_sqlite3'

require 'logger'

class StateMachine

  include ActionSupport
  include ActionLoader
  include DataAccessSqlite3

  # Constructor
  # @param args Argument Hash
  def initialize(args = {})

    args[:run_state] = 'NORMAL' if args[:run_state].nil?

    @control = {
        run_state: args[:run_state],
        breakout: false,
        phase: 'STARTUP',
        actions: {},
        user_actions_dir: args[:user_actions_dir],
        number_of_actions: 0,
        log: args[:log],
        sqlite3_db: args[:sqlite3_db]
    }

    @logger = set_logger(Logger::DEBUG, @control[:log])
    @logger.info('Starting State Machine')
  end

  # Create the control database
  def create_db
    raise('Path to database must be set via sqlite3_db=(sqlite3_db) or constructor') if
        @control[:sqlite3_db].nil?
    delete_db(@control)
    create_tables(@control)
  end

  # Load the default and user actions if existing
  def load_actions
    load_default_actions(@control)
    load_user_actions(@control) unless @control[:user_actions_dir].nil?
    @control[:number_of_actions] = @control[:actions].size
  end

  # Main state machine loop
  def execute
    until @control[:breakout] do
      @control[:actions].each_value do |action|
        action.execute(@control)
        break if @control[:breakout]
      end
    end
  end

  def user_actions_dir
    @control[:user_actions_dir]
  end

  def user_actions_dir=(path)
    @control[:user_actions_dir] = path
  end

  def number_of_actions
    @control[:number_of_actions]
  end

  def log
    @control[:log]
  end

  def sqlite3_db
    @control[:sqlite3_db]
  end

  def sqlite3_db=(sqlite3_db)
    @control[:sqlite3_db] = sqlite3_db
    create_db
  end

end


