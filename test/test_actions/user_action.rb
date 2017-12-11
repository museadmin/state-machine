require 'state/actions/action'

class UserAction < Action

  attr_accessor :flag, :phase, :state, :payload

  def initialize(control)
    @flag = 'SAMPLE_USER_ACTION'
    @phase = 'STARTUP'
    @state = 'SKIP'
    @payload = 'NULL'
    save_action(self, control)
  end

  def execute(control)

    if control[:phase] == @phase && @state == 'ACT'
      puts @flag
      File.write('/tmp/UserAction', :SAMPLE_USER_ACTION)
      control[:breakout] = true
    end

  end

end