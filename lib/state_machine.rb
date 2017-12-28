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

  attr_reader :run_dir

  # Constructor for State Machine
  # @param args Argument Hash
  def initialize(args = {})
    # State machine control
    @run_mode = args.fetch(:run_mode) { 'NORMAL' }
    @actions = {}
    @user_actions_dir = args[:user_actions_dir]
    # Logging
    @log = nil
    @logger = nil
    @log_level = args.fetch(:log_level) { Logger::DEBUG }
    # Control DB
    @sqlite3_db = nil
    # The run directories
    @run_root = args.fetch(:run_root) { "#{Dir.home}/state_machine_root" }
    @user_tag = args.fetch(:run_root) { 'default' }
    @run_tag = (Time.now.to_f * 1000).to_i
    @run_dir = nil

    create_run_environment
    insert_runtime_properties
    set_logging
  end

  def include_module(type)
    if Module.const_defined?(type)
      self.singleton_class.send(:include, Module.const_get(type))
    end
  end

  # Setup the logging
  def set_logging
    @log = "#{@run_dir}/log/run.log"
    @logger = set_logger(@log_level, @log)
    @logger.info('Starting State Machine')
  end

  # Add these properties to the properties table in db
  def insert_runtime_properties
    insert_property('user_actions_dir', @user_actions_dir)
    insert_property('run_root', @run_root)
    insert_property('user_tag', @user_tag)
    insert_property('run_tag', @run_tag)
    insert_property('run_dir', @run_dir)
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
      @actions.each_value do |action|
        action.execute
        break if breakout
      end
    end
  end

  # Create the control database
  def create_db
    # @db_file = @sqlite3_db
    delete_db
    create_tables
  end

  # Load the default and user actions if existing
  def load_actions
    load_default_actions
    load_user_actions unless @user_actions_dir.nil?
    update_state('ACTIONS_LOADED', 1)
  end

  def number_of_actions
    @actions.size
  end

  # Create the default runtime directories
  def create_run_dirs
    @run_dir = Pathname.new(
      "#{@run_root}/#{@user_tag}/#{@run_tag}"
    )
    FileUtils.mkdir_p(@run_dir)
    FileUtils.mkdir("#{@run_dir}/data")
    FileUtils.mkdir("#{@run_dir}/log")
    FileUtils.chmod_R('u=wrx,go=r', @run_dir)
    @sqlite3_db = "#{@run_dir}/data/state-machine.db"
  end
end