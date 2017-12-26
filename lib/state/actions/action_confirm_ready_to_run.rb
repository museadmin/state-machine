# frozen_string_literal: true

require 'state/actions/parent_action'

# Check we're ready to run and then change state
class ActionConfirmReadyToRun < ParentAction
  def initialize(sqlite3_db, run_mode, flag)
    @flag = flag
    if run_mode == 'NORMAL'
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
      ['0', 'READY_TO_RUN', 'We are ready to run']
    ]
  end

  def execute
    return unless active
    update_run_phase_state('RUNNING')
    update_state('READY_TO_RUN', 1)
  end
end
