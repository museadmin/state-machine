# frozen_string_literal: true

require 'state/actions/parent_action'

# A test action
class ActionSecondaryUser < ParentAction
  def initialize(args, flag)
    @flag = flag
    if args[:run_mode] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = 'SKIP'
      @payload = 'NULL'
      super(args[:sqlite3_db], args[:logger])
    else
      recover_action(self)
    end
  end

  def states
    [
      ['0', 'SECONDARY_TEST_STATE', 'A test state for the unit tests']
    ]
  end

  def execute
    return unless active
    # Write out proof we were here for unit test
    File.write('/tmp/UserAction', :SECONDARY_USER_ACTION)
    # Trigger the shutdown process
    normal_shutdown
    deactivate(@flag)
  end
end