# frozen_string_literal: true

require 'state/actions/parent_action'

# Action an emergency shutdown
class ActionEmergencyShutdown < ParentAction
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
      ['0', 'EMERGENCY_SHUTDOWN',
       'State machine has a bug, cannot be trusted']
    ]
  end

  def execute
    return unless active
    update_state('EMERGENCY_SHUTDOWN', 1)
    update_state('RUNNING', 0)
    update_state('READY_TO_RUN', 0)
    update_property('phase', 'SHUTDOWN')
    update_state('BREAKOUT', 1)
  end
end
