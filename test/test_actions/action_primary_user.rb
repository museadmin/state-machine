# frozen_string_literal: true

require 'state/actions/parent_action'

# A test action
class ActionPrimaryUser < ParentAction
  def initialize(args, flag)
    @flag = flag
    if args[:run_mode] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = 'ACT'
      @payload = 'NULL'
      super(args[:sqlite3_db], args[:logger])
    else
      recover_action(self)
    end
  end

  def states
    [
      ['0', 'PRIMARY_TEST_STATE', 'A test state for the unit tests']
    ]
  end

  def execute
    return unless active
    activate(flag: 'ACTION_SECONDARY_USER')
    deactivate(@flag)
  end
end