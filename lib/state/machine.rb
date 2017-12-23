require 'state/machine/version'
require 'state/required_actions'
require 'state/support/action_loader'
require 'state/support/action_support'
require 'state/support/standing_data'
require 'state/support/data_access_sqlite3'

require 'logger'

class StateMachine

  include ActionSupport
  include ActionLoader
  include DataAccessSqlite3

  # TODO Convert to use a gem as well as a directory of classes
  # needs creating another gem first...
  # then refactor load actions

  # Constructor for State Machine
  # @param args Argument Hash
  def initialize(args = {})

    args[:run_state] = 'NORMAL' if args[:run_state].nil?

    @control = {
      # State machine control
      run_state: args.fetch(:run_state) { 'NORMAL' },
      actions: {},
      number_of_actions: 0,
      user_actions_dir: args[:user_actions_dir],

      # Logging
      log_level: args.fetch(:log_level) { Logger::DEBUG },

      # Control DB
      sqlite3_db: nil,

      # The run directories
      run_root: args.fetch(:run_root) { "#{Dir.home}/state_machine_root" },
      user_tag: args.fetch(:run_root) { "default" },
      run_tag: Time.now.to_f,
      run_dir: nil
    }

    # Create the runtime environment
    create_run_dirs
    create_db
    insert_states(default_states)

    insert_property('run_state', args.fetch(:run_state) { 'NORMAL' })
    insert_property('breakout', false )
    insert_property('user_actions_dir', args.fetch(:user_actions_dir) { 'NULL' })
    insert_property('phase', 'STARTUP')
    insert_property('run_root',  @control[:run_root])
    insert_property('user_tag', @control[:user_tag])
    insert_property('run_tag', @control[:run_tag])

    # Setup the logger
    @control[:log] = "#{@control[:run_dir]}/log/run.log"
    @logger = set_logger(@control[:log_level], @control[:log])
    @logger.info('Starting State Machine')

  end

  def breakout
    (query_property('breakout').to_s =~ /^[Tt]rue$/i) == 0
  end

  # Main state machine loop
  def execute
    until breakout do
      @control[:actions].each_value do |action|
        action.execute(@control)
        break if breakout
      end
    end
  end

  # Create the control database
  def create_db
    set_db_file(@control[:sqlite3_db])
    delete_db
    create_tables
  end

  # Load the default and user actions if existing
  def load_actions
    load_default_actions(@control)
    load_user_actions(@control) unless @control[:user_actions_dir].nil?
    @control[:number_of_actions] = @control[:actions].size
    update_state('ACTIONS_LOADED', 1)
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


