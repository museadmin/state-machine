require 'state/actions/parent_action'

class ActionConfirmReadyToRun < ParentAction

  def initialize(control)

    @flag = 'CONFIRM_READY_TO_RUN'

    @states = [
        ['0', 'READY_TO_RUN', 'We are ready to run']
    ]

    if control[:run_state] == 'NORMAL'
      @phase = 'ALL'
      @activation = 'ACT'
      @payload = 'NULL'
      super(control)
    elsif
      recover_action(self, control)
    end

  end

  def execute(control)

    if check_phase(@phase, control) && @activation == 'ACT'
      # Check the state flags that indicate we're ready to run
      puts @flag
      update_state('READY_TO_RUN', 1, control)
      update_state('RUNNING', 1, control)
      control[:phase] = 'RUNNING'
    end

  ensure
    update_action(self, control)
  end

end
