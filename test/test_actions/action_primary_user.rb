# frozen_string_literal: true

require 'state/actions/parent_action'

# A test action
class ActionPrimaryUser < ParentAction
  def initialize(control, flag)
    @flag = flag
    if control[:run_state] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = 'ACT'
      @payload = 'NULL'
      super(control)
    else
      recover_action(self)
    end
  end

  def states
    [
        ['0', 'PRIMARY_TEST_STATE', 'A test state for the unit tests']
    ]
  end

  def execute(control)
    return unless active

    control[:actions]['ACTION_SECONDARY_USER'].activation = 'ACT'
    control[:actions]['ACTION_PRIMARY_USER'].activation = 'SKIP'
  end
end