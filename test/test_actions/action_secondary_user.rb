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
      recover_action(self)
    end
  end

  def execute(control)

    if active(control)

      puts @flag

      # Write out proof we were here for unit test
      File.write('/tmp/UserAction', :SECONDARY_USER_ACTION)
      # Trigger the shutdown process
      control[:actions]['NORMAL_SHUTDOWN'].activation = 'ACT'
    end

  end

end