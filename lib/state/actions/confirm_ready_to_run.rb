require 'state/actions/action'

class ConfirmReadyToRun < Action

  attr_accessor :flag, :phase, :state, :payload

  def initialize(control)
    @flag = 'CONFIRM_READY_TO_RUN'
    if control[:run_state] == 'NORMAL'
      @phase = 'STARTUP'
      @state = 'ACT'
      @payload = 'NULL'
      save_state(self, control)
    elsif
      recover_state(self, control)
    end
  end

  def execute(control)

    if control[:phase] == @phase && @state == 'ACT'
      # Action Code Here
      puts @flag
      
      @state = 'SKIP'
    end

  ensure
    update_action(self, control)
  end

end
