require 'state/actions/action'

class PrimaryUserAction < Action

  attr_accessor :flag, :phase, :state, :payload

  def initialize(control)
    @flag = 'PRIMARY_USER_ACTION'

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
      puts @flag
      File.write('/tmp/UserAction', :SECONDARY_USER_ACTION)
      control[:actions]['SECONDARY_USER_ACTION'].state = 'ACT'
    end

  end

end