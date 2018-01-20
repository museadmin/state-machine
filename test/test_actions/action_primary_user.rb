# frozen_string_literal: true

require 'state/actions/parent_action'

# A test action
class ActionPrimaryUser < ParentAction
  # Instantiate the action
  # @param args [Hash] Required parameters for the action
  # @param action [String] Name of action
  def initialize(args, action)
    @action = action
    if args[:run_mode] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = ACT
      @payload = 'NULL'
      super(args[:logger])
    else
      recover_action(self)
    end
  end

  # Do the work for this action
  def execute
    return unless active
    activate(action: 'ACTION_SECONDARY_USER')
    deactivate(@action)
  end

  private

  # States for this action
  def states
    [
        ['0', 'PRIMARY_TEST_STATE', 'A test state for the unit tests']
    ]
  end
end