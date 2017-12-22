require 'state/actions/parent_action'

class ActionSecondaryUser < ParentAction

  def initialize(control)

    @flag = 'SECONDARY_USER_ACTION'
    @states = [
      ['0', 'SECONDARY_TEST_STATE', 'A test state for the unit tests']
    ]

    if control[:run_state] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = 'SKIP'
      @payload = 'NULL'
      super(control)
    elsif
      recover_action(self, control)
    end
  end

  def execute(control)

    if check_phase(@phase, control) && @activation == 'ACT'
      puts @flag
      File.write('/tmp/UserAction', :SECONDARY_USER_ACTION)
      control[:breakout] = true
    end

  end

end