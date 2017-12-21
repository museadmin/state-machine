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

  # Constructor for State Machine
  # @param args Argument Hash
  def initialize(args = {})

    args[:run_state] = 'NORMAL' if args[:run_state].nil?

    @control = {
      # State machine control
      run_state: args.fetch(:run_state) { 'NORMAL' },
      breakout: false,
      actions: {},
      number_of_actions: 0,
      user_actions_dir: args[:user_actions_dir],
      phase: 'STARTUP',
      # Logging
      log: args[:log],
      log_level: args.fetch(:log_level) { Logger::DEBUG },
      # Control DB
      sqlite3_db: args[:sqlite3_db],
      # The run directories
      run_root: args.fetch(:run_root) { "#{Dir.home}/state_machine_root" },
      user_tag: args.fetch(:run_root) { "default" },
      run_tag: Time.now.to_f,
      run_dir: nil
    }

    # Create the runtime environment
    create_run_dirs
    create_db

    # Setup the logger
    @control[:log] = "#{@control[:run_dir]}/log/run.log" if @control[:log].nil?
    @logger = set_logger(@control[:log_level], @control[:log])
    @logger.info('Starting State Machine')

  end

  # Create the control database
  def create_db
    raise 'Unable to determine run data directory' if @control[:sqlite3_db].nil?
    delete_db(@control)
    create_tables(@control)
    insert_standing_data(@control)
  end

  # Load the default and user actions if existing
  def load_actions
    load_default_actions(@control)
    load_user_actions(@control) unless @control[:user_actions_dir].nil?
    @control[:number_of_actions] = @control[:actions].size
    update_state('ACTIONS_LOADED', 1, @control)
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
  
  def run_root
    @control[:run_root]
  end
  
  def run_root=(path)
    @control[:run_root] = path
  end
  
  def create_run_dirs
    @control[:run_dir] = Pathname.new("#{@control[:run_root]}/#{@control[:user_tag]}/#{@control[:run_tag]}")
    FileUtils.mkdir_p(@control[:run_dir])
    FileUtils.mkdir("#{@control[:run_dir]}/data")
    FileUtils.mkdir("#{@control[:run_dir]}/log")
    FileUtils.chmod_R('u=wrx,go=r', @control[:run_dir])

    @control[:sqlite3_db] = "#{@control[:run_dir]}/data/state-machine.db"

  end

end


