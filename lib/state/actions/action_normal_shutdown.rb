# frozen_string_literal: true

require 'state/actions/parent_action'

# Action a normal shutdown
class ActionNormalShutdown < ParentAction
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
        ['0', 'SHUTDOWN', 'We are shutting down normally']
    ]
  end

  def execute
    if active
      run_phase = RunPhase.new
      run_phase.shutdown = 1
      update_run_phase_state(run_phase)

      update_state('READY_TO_RUN', 0)
      update_property('phase', 'SHUTDOWN')
      update_state('BREAKOUT', 1)
    end
  end
end
