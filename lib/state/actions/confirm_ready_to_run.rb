require 'state/actions/action'

class ConfirmReadyToRun < Action

  attr_accessor :flag, :phase, :state, :payload

  def initialize(control)

    @flag = 'CONFIRM_READY_TO_RUN'

    if control[:run_state] == 'NORMAL'
      @phase = 'STARTUP'
      @state = 'ACT'
      @payload = 'NULL'
      save_action(self, control)
    elsif
      recover_action(self, control)
    end

  end

  def execute(control)

    if control[:phase] == @phase && @state == 'ACT'
      # Check the state flags that indicate we're ready to run
      puts @flag
      
      @state = 'SKIP'
    end

  ensure
    update_action(self, control)
  end

end
