# frozen_string_literal: true

require 'minitest/autorun'
require 'state_machine'
require 'eventmachine'

USER_ACTIONS_DIR = './test/test_actions'
OTHER_ACTIONS = '/some/path'
TMP_FILE = '/tmp/UserAction'
ACTION_STATEMENT = 'SECONDARY_USER_ACTION'
LOG_FILE = '/tmp/logfile.log'
TEST_LOG = '/tmp/test.log'
DB_FILE = '../state-machine-dev/database/state-machine.db'
RESULTS_ROOT = "#{Dir.home}/state_machine_root"

# Unit tests for the state machine object
class StateMachineTest < Minitest::Test

  # Disable this if debugging a failure...
  def teardown
    return unless File.directory?(RESULTS_ROOT)
    FileUtils.rm_rf("#{RESULTS_ROOT}/.", secure: true)
  end

  # Confirm that the version number is set
  def test_that_it_has_a_version_number
    refute_nil ::State::Machine::VERSION
  end

  # Test that the state machine load a test action pack
  def test_execution_of_user_actions
    File.delete(TMP_FILE) if File.file? TMP_FILE

    sm = StateMachine.new
    sm.import_action_pack(USER_ACTIONS_DIR)
    sm.execute

    wait_for_run_phase('SHUTDOWN', sm, 10)

    assert File.file? TMP_FILE
    assert_equal File.open(TMP_FILE, &:gets), ACTION_STATEMENT
    File.delete(TMP_FILE)
  end

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
        if state_machine.query_run_phase_state == phase
          p.cancel
          t.cancel
          EM.stop
          return true
        end
      end
    end
  end
end