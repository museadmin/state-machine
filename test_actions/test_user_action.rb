
class TestUserAction

  attr_accessor :flag, :phase, :state

  def initialize
    @flag = 'SAMPLE_USER_ACTION'
    @phase = 'STARTUP'
    @state = 'ACT'
  end

  def execute(phase)
    if @phase == phase && @state == 'ACT'
      puts @flag
      puts phase
      File.write('/tmp/TestUserAction', :SAMPLE_USER_ACTION)
    end
  end

end