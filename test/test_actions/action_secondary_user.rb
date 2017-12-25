# frozen_string_literal: true

require 'state/actions/parent_action'

# A test action
class ActionSecondaryUser < ParentAction
  def initialize(control, flag)
    @flag = flag
    if control[:run_state] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = 'SKIP'
      @payload = 'NULL'
      super(control)
    else
      recover_action(self)
    end
  end

  def states
    [
        ['0', 'SECONDARY_TEST_STATE', 'A test state for the unit tests']
    ]
  end

  def execute(control)
    return unless active
    # Write out proof we were here for unit test
    File.write('/tmp/UserAction', :SECONDARY_USER_ACTION)
    # Trigger the shutdown process
    normal_shutdown(control)
    @activation = 'SKIP'
  end
end