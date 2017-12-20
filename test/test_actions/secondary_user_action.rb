require 'state/actions/action'

class SecondaryUserAction < Action

  attr_accessor :flag, :phase, :state, :payload

  def initialize(control)
    @flag = 'SECONDARY_USER_ACTION'
    if control[:run_state] == 'NORMAL'
      @phase = 'STARTUP'
      @state = 'SKIP'
      @payload = 'NULL'
      save_state(self, control)
    elsif
      recover_state(self, control)
    end
  end

  def execute(control)

    if control[:phase] == @phase && @state == 'ACT'
      puts @flag
      File.write('/tmp/UserAction', :SECONDARY_USER_ACTION)
      control[:breakout] = true
    end

  end

end