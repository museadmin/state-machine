require 'state/actions/parent_action'

class ActionPrimaryUser < ParentAction

  def initialize(control)

    @flag = 'PRIMARY_USER_ACTION'

    @states = [
        ['0', 'PRIMARY_TEST_STATE', 'A test state for the unit tests']
    ]

    if control[:run_state] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = 'ACT'
      @payload = 'NULL'
      super(control)
    elsif
      recover_action(self, control)
    end

  end

  def execute(control)

    if check_phase(@phase, control) && @activation == 'ACT'
      puts @flag
      control[:actions]['SECONDARY_USER_ACTION'].activation = 'ACT'
    end

  end

end