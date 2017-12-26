# frozen_string_literal: true

require 'state/actions/parent_action'

# Action an emergency shutdown
class ActionEmergencyShutdown < ParentAction
  def initialize(sqlite3_db, run_state, flag)
    @flag = flag
    if run_state == 'NORMAL'
      @phase = 'ALL'
      @activation = 'SKIP'
      @payload = 'NULL'
      super(sqlite3_db)
    else
      recover_action(self)
    end
  end

  def states
    [
        ['0', 'EMERGENCY_SHUTDOWN',
         'State machine has a bug, cannot be trusted']
    ]
  end

  def execute
    if active
      update_state('EMERGENCY_SHUTDOWN', 1)
      update_state('RUNNING', 0)
      update_state('READY_TO_RUN', 0)
      update_property('phase', 'SHUTDOWN')
      update_state('BREAKOUT', 1)
    end
  end
end
