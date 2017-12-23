require 'state/actions/parent_action'

class ActionEmergencyShutdown < ParentAction

  def initialize(control)

    @flag = 'EMERGENCY_SHUTDOWN'

    @states = [
        ['0', 'EMERGENCY_SHUTDOWN', 'State machine has a bug, cannot be trusted']
    ]

    if control[:run_state] == 'NORMAL'
      @phase = 'ALL'
      @activation = 'SKIP'
      @payload = 'NULL'
      super(control)
    elsif
      recover_action(self)
    end

  end

  def execute(control)

    if active

      # Check the state flags that indicate we're ready to run
      puts @flag

      update_state('EMERGENCY_SHUTDOWN', 1)
      update_state('RUNNING', 0)
      update_state('READY_TO_RUN', 0)
      update_property('phase', 'SHUTDOWN')
      update_property('breakout', true)
    end

  ensure
    update_action(self)
  end

end
