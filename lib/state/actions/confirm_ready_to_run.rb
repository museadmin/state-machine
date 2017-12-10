
class ConfirmReadyToRun

  attr_accessor :flag, :phase, :state, :payload

  def initialize
    @flag = 'CONFIRM_READY_TO_RUN'
    @phase = 'STARTUP'
    @state = 'ACT'
    @payload = nil
  end

  def execute(args)

    if args[:phase] == phase && @state == 'ACT'
      puts @flag
    end

  end

end
