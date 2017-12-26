# frozen_string_literal: true

require 'state/actions/parent_action'

# A test action
class ActionPrimaryUser < ParentAction
  def initialize(sqlite3_db, run_mode, flag)
    @flag = flag
    if run_mode == 'NORMAL'
      @phase = 'RUNNING'
      @activation = 'ACT'
      @payload = 'NULL'
      super(sqlite3_db)
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
    activate('ACTION_SECONDARY_USER')
    deactivate(@flag)
  end
end