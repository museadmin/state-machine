require 'state/actions/action'

class PrimaryUserAction < Action

  attr_accessor :flag, :phase, :state, :payload

  def initialize(control)
    @flag = 'PRIMARY_USER_ACTION'
    @phase = 'STARTUP'
    @state = 'ACT'
    @payload = 'NULL'
    save_action(self, control)
  end

  def execute(control)

    if control[:phase] == @phase && @state == 'ACT'
      puts @flag
      File.write('/tmp/UserAction', :SAMPLE_USER_ACTION)
      control[:actions]['SAMPLE_USER_ACTION'].state = 'ACT'
    end

  end

end