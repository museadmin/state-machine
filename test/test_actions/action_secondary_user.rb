# frozen_string_literal: true

require 'state/actions/parent_action'

# A test action
class ActionSecondaryUser < ParentAction
  # Instantiate the action
  # @param args [Hash] Required parameters for the action
  # @param action [String] Name of action
  def initialize(args, action)
    @action = action
    if args[:run_mode] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = SKIP
      @payload = 'NULL'
      super(args[:logger])
    else
      recover_action(self)
    end
  end

  # Do the work for this action
  def execute
    return unless active
    # Write out proof we were here for unit test
    File.write('/tmp/UserAction', :SECONDARY_USER_ACTION)
    # Trigger the shutdown process
    normal_shutdown
    deactivate(@action)
  end

  private

  # States for this action
  def states
    [
        ['0', 'SECONDARY_TEST_STATE', 'A test state for the unit tests']
    ]
  end
end