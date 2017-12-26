# frozen_string_literal: true

require 'state/actions/parent_action'

# Check we're ready to run and then change state
class ActionConfirmReadyToRun < ParentAction
  def initialize(sqlite3_db, run_state, flag)
    @flag = flag
    if run_state == 'NORMAL'
      @phase = 'ALL'
      @activation = 'ACT'
      @payload = 'NULL'
      super(sqlite3_db)
    else
      recover_action(self)
    end
  end

  def states
    [
        ['0', 'RUNNING', 'We are running normally'],
        ['0', 'READY_TO_RUN', 'We are ready to run']
    ]
  end

  def execute
    if active
      # TODO: Check the state flags that indicate we're ready to run
      # For now assume we're ready
      update_state('STARTUP', 0)
      update_state('READY_TO_RUN', 1)
      update_state('RUNNING', 1)
      update_property('phase', 'RUNNING')
    end
  end
end
