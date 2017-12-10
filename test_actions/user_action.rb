
class UserAction

  attr_accessor :flag, :phase, :state, :payload

  def initialize
    @flag = 'SAMPLE_USER_ACTION'
    @phase = 'STARTUP'
    @state = 'SKIP'
    @payload = nil
  end

  def execute(args)

    if args[:phase] == phase && @state == 'ACT'
      puts @flag
      File.write('/tmp/UserAction', :SAMPLE_USER_ACTION)
      args[:control][:breakout] = true
    end

  end

end