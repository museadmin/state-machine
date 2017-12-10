
class ConfirmReadyToRun

  attr_accessor :flag, :phase, :state

  def initialize
    @flag = 'CONFIRM_READY_TO_RUN'
    @phase = 'STARTUP'
    @state = 'ACT'
  end

  def execute(phase)
    if @phase == phase && @state == 'ACT'
      puts @flag
      puts phase
    end
  end

end
