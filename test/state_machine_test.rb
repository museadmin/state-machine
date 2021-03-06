# frozen_string_literal: true

require 'minitest/autorun'
require 'state_machine'
require 'eventmachine'

USER_ACTIONS_DIR = './test/test_actions'
OTHER_ACTIONS = '/some/path'
TEST_ACTION_RESULT_FILE = '/tmp/UserAction'
TEST_AFTER_RESULT_FILE =  '/tmp/AfterAction'
TEST_FINALLY_RESULT_FILE = '/tmp/FinallyAction'
ACTION_STATEMENT = 'SECONDARY_USER_ACTION'
LOG_FILE = '/tmp/logfile.log'
TEST_LOG = '/tmp/test.log'
DB_FILE = '../state-machine-dev/database/state-machine.db'
RESULTS_ROOT = "#{Dir.home}/state_machine_root"
USER_TAG = 'test_set_of_user_tag'

# Unit tests for the state machine object
class StateMachineTest < Minitest::Test

  # Disable this if debugging a failure...
  TEARDOWN = false
  def teardown
    return unless TEARDOWN && File.directory?(RESULTS_ROOT)
    FileUtils.rm_rf("#{RESULTS_ROOT}/.", secure: true)
  end

  # Confirm that the version number is set
  def test_that_it_has_a_version_number
    refute_nil ::State::Machine::VERSION
  end

  # Test that the state machine load a test action pack
  # Demonstrate setting debug level
  def test_execution_of_user_actions
    File.delete(TEST_ACTION_RESULT_FILE) if File.file? TEST_ACTION_RESULT_FILE

    sm = StateMachine.new(log_level: Logger::DEBUG)
    sm.import_action_pack(path: USER_ACTIONS_DIR, name: 'state_machine')
    sm.execute

    # Test actions set shutdown flag so wait for phase change
    wait_for_run_phase('SHUTDOWN', sm, 10)

    # Assert the test action wrote out to file
    assert File.file? TEST_ACTION_RESULT_FILE
    assert_equal File.open(TEST_ACTION_RESULT_FILE, &:gets), ACTION_STATEMENT
    File.delete(TEST_ACTION_RESULT_FILE)
  end

  # Test the after action hook functionality
  def test_execution_of_after_actions
    File.delete(TEST_ACTION_RESULT_FILE) if File.file? TEST_ACTION_RESULT_FILE

    sm = StateMachine.new(log_level: Logger::DEBUG)
    sm.import_action_pack(path: USER_ACTIONS_DIR, name: 'state_machine')
    sm.execute

    # Test actions set shutdown flag so wait for phase change
    wait_for_run_phase('STOPPED', sm, 10)

    # Assert the after action wrote out to file
    assert File.file? TEST_AFTER_RESULT_FILE
    assert_equal(File.open(TEST_AFTER_RESULT_FILE, &:gets), 'ACTION_AFTER_TEST')
    File.delete(TEST_AFTER_RESULT_FILE)
  end

  # Test the finally action hook functionality
  def test_execution_of_finally_actions
    File.delete(TEST_ACTION_RESULT_FILE) if File.file? TEST_ACTION_RESULT_FILE

    sm = StateMachine.new(log_level: Logger::DEBUG)
    sm.import_action_pack(path: USER_ACTIONS_DIR, name: 'state_machine')
    sm.execute

    # Test actions set shutdown flag so wait for phase change
    # wait_for_run_phase('RUNNING', sm, 10)
    wait_for_run_phase('STOPPED', sm, 10)

    # Assert the after action wrote out to file
    assert File.file? TEST_FINALLY_RESULT_FILE
    assert_equal(File.open(TEST_FINALLY_RESULT_FILE, &:gets), 'ACTION_FINALLY_TEST')
    File.delete(TEST_FINALLY_RESULT_FILE)
  end

  # Test that the user_tag is set correctly
  def test_set_of_user_tag
    sm = StateMachine.new(user_tag: USER_TAG, log_level: Logger::DEBUG)
    user_tag = sm.query_property('user_tag')
    run_root = sm.query_property('run_root')
    assert(user_tag == USER_TAG)
    assert(Dir.exist?("#{run_root}/#{user_tag}"))
  end

  # Test the dependency check
  # In action pack export:
  #
  # Add name of dependent gems to args[:dependencies]
  # Pass to sm import action pack method
  #
  # in sm add any dependencies defined to a dependencies table
  #
  # After all packs imported, run a check to see if all deps are installed
  #
  # Gem.loaded_specs.each_key do |k|
  #   puts k
  # end
  #
  # Lists all installed gem names so can read them all into an array and then
  # iterate over the dependencies, checking if each in array

  # Wait for a change of run phase in the state machine.
  # Raise error if timeout.
  # @param phase [String] Name of phase to wait for
  # @param state_machine [StateMachine] An instance of a state machine
  # @param time_out [FixedNum] The time out period
  def wait_for_run_phase(phase, state_machine, time_out)
    EM.run do
      t = EM::Timer.new(time_out) do
        EM.stop
        return false
      end

      p = EM::PeriodicTimer.new(1) do
        begin
          if state_machine.query_run_phase_state == phase
            p.cancel
            t.cancel
            EM.stop
            return true
          end
        rescue SQLite3::Exception
            x = 0
        end
      end
    end
  end
end