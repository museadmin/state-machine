require 'state/actions/parent_action'

class ActionConfirmReadyToRun < ParentAction

  def initialize(control)

    @flag = 'CONFIRM_READY_TO_RUN'

    @states = [
        ['0', 'RUNNING', 'We are running normally'],
        ['0', 'READY_TO_RUN', 'We are ready to run']
    ]

    if control[:run_state] == 'NORMAL'
      @phase = 'ALL'
      @activation = 'ACT'
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

      update_state('READY_TO_RUN', 1)
      update_state('RUNNING', 1)
      update_state('STARTUP', 0)
      update_property('phase', 'RUNNING')
    end

  ensure
    update_action(self)
  end

end
