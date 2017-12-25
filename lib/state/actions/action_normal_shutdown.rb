# frozen_string_literal: true

require 'state/actions/parent_action'

# Action a normal shutdown
class ActionNormalShutdown < ParentAction
  def initialize(control, flag)
    @flag = flag
    if control[:run_state] == 'NORMAL'
      @phase = 'ALL'
      @activation = 'SKIP'
      @payload = 'NULL'
      super(control)
    else
      recover_action(self)
    end
  end

  def states
    [
        ['0', 'SHUTDOWN', 'We are shutting down normally']
    ]
  end

  def execute(control)
    if active
      update_state('SHUTDOWN', 1)
      update_state('RUNNING', 0)
      update_state('READY_TO_RUN', 0)
      update_property('phase', 'SHUTDOWN')
      update_property('breakout', true)
    end
  ensure
    update_action(self)
  end
end
