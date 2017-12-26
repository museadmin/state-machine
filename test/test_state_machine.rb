# frozen_string_literal: true

require 'minitest/autorun'
require 'state_machine'

USER_ACTIONS_DIR = './test/test_actions'
OTHER_ACTIONS = '/some/path'
TMP_FILE = '/tmp/UserAction'
ACTION_STATEMENT = 'SECONDARY_USER_ACTION'
LOG_FILE = '/tmp/logfile.log'
TEST_LOG = '/tmp/test.log'
DB_FILE = '../state-machine-dev/database/state-machine.db'

class StateMachineTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::State::Machine::VERSION
  end

  def test_execution_of_user_actions
    File.delete(TMP_FILE) if File.file? TMP_FILE

    sm = StateMachine.new(user_actions_dir: USER_ACTIONS_DIR)
    sm.load_actions
    sm.execute

    assert File.file? TMP_FILE
    assert_equal File.open(TMP_FILE, &:gets), ACTION_STATEMENT
    File.delete(TMP_FILE)
  end

  # TODO: Test for passing a payload to an action
end