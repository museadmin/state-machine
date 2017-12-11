require 'minitest/autorun'
require 'state/machine'

USER_ACTIONS = './test/test_actions'
OTHER_ACTIONS = '/some/path'
TMP_FILE = '/tmp/UserAction'
ACTION_STATEMENT = 'SAMPLE_USER_ACTION'
LOG_FILE = '/tmp/logfile.log'
TEST_LOG = '/tmp/test.log'

class StateMachineTest < Minitest::Test

  def test_set_of_user_actions_location
    sm = StateMachine.new({user_actions: USER_ACTIONS})
    assert_equal USER_ACTIONS, sm.user_actions
    sm.user_actions = OTHER_ACTIONS
    assert_equal OTHER_ACTIONS, sm.user_actions
  end

  def test_load_of_user_actions
    sm = StateMachine.new({user_actions: USER_ACTIONS})
    assert sm.number_of_actions == 0
    sm.load_actions
    assert sm.number_of_actions > 0
  end

  def test_execution_of_user_actions
    File.delete(TMP_FILE) if File.file? TMP_FILE

    sm = StateMachine.new({user_actions: USER_ACTIONS})
    sm.load_actions
    sm.execute

    assert File.file? TMP_FILE
    assert_equal File.open(TMP_FILE, &:gets), ACTION_STATEMENT
    File.delete(TMP_FILE)
  end

  def test_set_of_log_location

    File.delete(TEST_LOG) if File.file? TEST_LOG

    sm = StateMachine.new({user_actions: USER_ACTIONS, log: TEST_LOG})
    assert sm.log == TEST_LOG
    sm.load_actions
    sm.execute
    assert File.file? TEST_LOG

    @found = false
    File.foreach(TEST_LOG) do |line|
      if line.include? 'Starting State Machine'
        @found = true
      end
    end
    assert @found

    File.delete(TEST_LOG)

  end

end