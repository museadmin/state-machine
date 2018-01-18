# frozen_string_literal: true

require 'state/machine/version'
require 'state/support/action_loader'
require 'state/support/action_support'
require 'state/support/standing_data'
require 'state/support/data_access_sqlite3'
require 'state/support/constants'

require 'logger'
require 'pathname'
require 'thread'

# The State Machine itself. Comes with a limited set of
# default actions and can import actions from 'action packs'.
# Not much use without action packs...
class StateMachine
  include ActionSupport
  include ActionLoader
  include DataAccessSqlite3

  attr_reader :run_dir

  # Constructor for State Machine
  # @param args Argument Hash
  # run_mode [Symbol] 'NORMAL' or 'RECOVERY'
  # log_level [Symbol] e.g. Logger::DEBUG
  # run_root [Symbol] The root of the run directory created for each run.
  # Defaults to $HOME/state_machine_root
  def initialize(args = {})
    # State machine control
    @run_mode = args.fetch(:run_mode) { 'NORMAL' }
    @actions = {}
    # Logging
    @log = nil
    @logger = nil
    @log_level = args.fetch(:log_level) { Logger::DEBUG }
    # Control DB
    @@sqlite3_db = nil
    @@db_lock = Mutex.new
    # The run directories
    @run_root = args.fetch(:run_root) { "#{Dir.home}/state_machine_root" }
    @user_tag = args.fetch(:run_root) { 'default' }
    @run_tag = (Time.now.to_f * 1000).to_i
    @run_dir = nil

    create_run_environment
    set_logging
    insert_runtime_properties
    load_default_actions
  end

  # Imports an action pack from a child project via its
  # export_action_pack method
  # @param path [String] The absolute path to the action pack
  def import_action_pack(path)
    load_action_pack(path) unless path.nil?
    update_state('ACTION_PACK_LOADED', 1)
  end

  # Returns the number of actions loaded into the state machine
  # @return [Integer] No of actions in actions array
  def number_of_actions
    @actions.size
  end

  # Main state machine loop. Will continue to execute until
  # the SYS_NORMAL_SHUTDOWN or SYS_EMERGENCY_SHUTDOWN action is activated
  def execute
    @logger.info('Starting State Machine')
    Thread.abort_on_exception = true
    Thread.new do
      until breakout
        @actions.each_value do |action|
          action.execute
          break if breakout
        end
      end
    end
  end

  # Include an external module from an action pack
  # @param type [String] Module name from child project
  # to import into state machine
  def include_module(type)
    if Module.const_defined?(type)
      self.singleton_class.send(:include, Module.const_get(type))
    end
  end

  # Query the state table for a particular state
  def query_status(flag)
    execute_sql_query(
      "select status from state where state_flag = '#{flag}';"
    )[0][0]
  end

  private

  # Setup the logging
  def set_logging
    @log = "#{@run_dir}/log/run.log"
    @logger = set_logger(@log_level, @log)
  end

  # Add these properties to the properties table in db
  def insert_runtime_properties
    insert_property('run_root', @run_root)
    insert_property('user_tag', @user_tag)
    insert_property('run_tag', @run_tag)
    insert_property('run_dir', @run_dir)
  end

  # Setup the runtime environment. Creates the run directories
  #   and the main control sqlite3 database
  def create_run_environment
    create_run_dirs
    create_db
    insert_states(default_states)
  end

  # Create the control database
  def create_db
    delete_db
    create_tables
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
    @@sqlite3_db = "#{@run_dir}/data/state-machine.db"
  end
end