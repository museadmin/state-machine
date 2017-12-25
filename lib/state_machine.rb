# frozen_string_literal: true

require 'state/machine/version'
require 'state/support/action_loader'
require 'state/support/action_support'
require 'state/support/standing_data'
require 'state/support/data_access_sqlite3'

require 'logger'

# The State Machine
class StateMachine
  include ActionSupport
  include ActionLoader
  include DataAccessSqlite3

  # Constructor for State Machine
  # @param args Argument Hash
  def initialize(args = {})
    @control = {
      # State machine control
      run_state: args.fetch(:run_state) { 'NORMAL' },
      actions: {},
      user_actions_dir: args[:user_actions_dir],
      # Logging
      log_level: args.fetch(:log_level) { Logger::DEBUG },
      # Control DB
      sqlite3_db: nil,
      # The run directories
      run_root: args.fetch(:run_root) { "#{Dir.home}/state_machine_root" },
      user_tag: args.fetch(:run_root) { 'default' },
      run_tag: Time.now.to_f,
      run_dir: nil
    }
    create_run_environment
    insert_runtime_properties(args)
    set_logging
  end

  # Setup the logging
  def set_logging
    @control[:log] = "#{@control[:run_dir]}/log/run.log"
    @logger = set_logger(@control[:log_level], @control[:log])
    @logger.info('Starting State Machine')
  end

  # Add these properties to the properties table in db
  # @param args As passed to initializer
  def insert_runtime_properties(args)
    insert_property('run_state', args.fetch(:run_state) { 'NORMAL' })
    insert_property('breakout', false)
    insert_property('user_actions_dir',
                    args.fetch(:user_actions_dir) { 'NULL' })
    insert_property('phase', 'STARTUP')
    insert_property('run_root', @control[:run_root])
    insert_property('user_tag', @control[:user_tag])
    insert_property('run_tag', @control[:run_tag])
  end

  # Setup the runtime environment
  def create_run_environment
    create_run_dirs
    create_db
    insert_states(default_states)
  end

  # Main state machine loop
  def execute
    until breakout
      @control[:actions].each_value do |action|
        action.execute(@control)
        break if breakout
      end
    end
  end

  # Create the control database
  def create_db
    @db_file = @control[:sqlite3_db]
    delete_db
    create_tables
  end

  # Load the default and user actions if existing
  def load_actions
    load_default_actions(@control)
    load_user_actions(@control) unless @control[:user_actions_dir].nil?
    update_state('ACTIONS_LOADED', 1)
  end

  def number_of_actions
    @control[:actions].size
  end

  # Create the default runtime directories
  def create_run_dirs
    @control[:run_dir] = Pathname.new(
      "#{@control[:run_root]}/#{@control[:user_tag]}/#{@control[:run_tag]}"
    )
    FileUtils.mkdir_p(@control[:run_dir])
    FileUtils.mkdir("#{@control[:run_dir]}/data")
    FileUtils.mkdir("#{@control[:run_dir]}/log")
    FileUtils.chmod_R('u=wrx,go=r', @control[:run_dir])
    @control[:sqlite3_db] = "#{@control[:run_dir]}/data/state-machine.db"
  end
end