
class PrimaryUserAction

  attr_accessor :flag, :phase, :state, :payload

  def initialize
    @flag = 'PRIMARY_USER_ACTION'
    @phase = 'STARTUP'
    @state = 'ACT'
    @payload = nil
  end

  def execute(args)

    if args[:phase] == phase && @state == 'ACT'
      puts @flag
      File.write('/tmp/UserAction', :SAMPLE_USER_ACTION)
      args[:actions]['SAMPLE_USER_ACTION'].state = 'ACT'
    end

  end

end