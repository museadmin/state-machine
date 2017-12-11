require 'state/actions/action'

class ConfirmReadyToRun < Action

  attr_accessor :flag, :phase, :state, :payload

  def initialize(control)
    @flag = 'CONFIRM_READY_TO_RUN'
    @phase = 'STARTUP'
    @state = 'ACT'
    @payload = 'NULL'
    save_action(self, control)
  end

  def execute(control)

    if control[:phase] == @phase && @state == 'ACT'
      puts @flag
    end

    @state = 'SKIP'
    update_action(self, control)

  end

end
