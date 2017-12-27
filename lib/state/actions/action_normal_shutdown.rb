# frozen_string_literal: true

require 'state/actions/parent_action'

# Action a normal shutdown
class ActionNormalShutdown < ParentAction
  def initialize(args, flag)
    @flag = flag
    if args[:run_mode] == 'NORMAL'
      @phase = 'ALL'
      @activation = 'SKIP'
      @payload = 'NULL'
      super(args[:sqlite3_db], args[:logger])
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
    return unless active
    update_run_phase_state('SHUTDOWN')
    update_state('READY_TO_RUN', 0)
    update_state('BREAKOUT', 1)
  end
end
