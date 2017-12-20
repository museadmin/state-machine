require 'minitest/autorun'
require 'state/machine'

USER_ACTIONS_DIR = './test/test_actions'
OTHER_ACTIONS = '/some/path'
TMP_FILE = '/tmp/UserAction'
ACTION_STATEMENT = 'SECONDARY_USER_ACTION'
LOG_FILE = '/tmp/logfile.log'
TEST_LOG = '/tmp/test.log'
DB_FILE = '../state-machine-dev/database/state-machine.db'

class StateMachineTest < Minitest::Test

  def test_set_of_user_actions_location
    sm = StateMachine.new({user_actions_dir: USER_ACTIONS_DIR})
    assert_equal USER_ACTIONS_DIR, sm.user_actions_dir
    sm.user_actions_dir = OTHER_ACTIONS
    assert_equal OTHER_ACTIONS, sm.user_actions_dir
  end

  def test_load_of_user_actions
    sm = StateMachine.new({user_actions: USER_ACTIONS_DIR})
    assert sm.number_of_actions == 0
    sm.load_actions
    assert sm.number_of_actions > 0
  end

  def test_execution_of_user_actions
    File.delete(TMP_FILE) if File.file? TMP_FILE

    sm = StateMachine.new({user_actions_dir: USER_ACTIONS_DIR})
    sm.load_actions
    sm.execute

    assert File.file? TMP_FILE
    assert_equal File.open(TMP_FILE, &:gets), ACTION_STATEMENT
    File.delete(TMP_FILE)
  end

  def test_set_of_log_location

    File.delete(TEST_LOG) if File.file? TEST_LOG

    sm = StateMachine.new(
        {
            user_actions_dir: USER_ACTIONS_DIR,
            log: TEST_LOG,
            sqlite3_db: DB_FILE
        }
    )
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

  def test_run_directory
    sm = StateMachine.new(
        {
            user_actions_dir: USER_ACTIONS_DIR,
            log: TEST_LOG
        }
    )

  end

end