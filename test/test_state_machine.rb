require 'minitest/autorun'
require 'state/machine'

USER_ACTIONS = '/Users/atkinsb/RubymineProjects/state-machine/test_actions'
OTHER_ACTIONS = '/some/path'
TMP_FILE = '/tmp/TestUserAction'
ACTION_STATEMENT = 'SAMPLE_USER_ACTION'

class StateMachineTest < Minitest::Test

  def test_set_user_actions
    sm = StateMachine.new(USER_ACTIONS)
    assert_equal USER_ACTIONS, sm.user_actions
    sm.user_actions = OTHER_ACTIONS
    assert_equal OTHER_ACTIONS, sm.user_actions
  end

  def test_load_user_actions
    sm = StateMachine.new(USER_ACTIONS)
    sm.load_actions
    assert sm.number_of_actions > 0
  end

  def test_execution_of_user_actions
    if File.file? TMP_FILE
      File.delete(TMP_FILE, 0)
    end
    sm = StateMachine.new(USER_ACTIONS)
    sm.load_actions
    sm.execute
    assert File.file? TMP_FILE
    assert_equal File.open(TMP_FILE, &:gets), ACTION_STATEMENT
    File.delete(TMP_FILE)
  end

end