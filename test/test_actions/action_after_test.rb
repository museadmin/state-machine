# frozen_string_literal: true

require 'state/actions/parent_action'

# A test action
class ActionAfterTest < ParentAction
  # Instantiate the action
  # @param args [Hash] Required parameters for the action
  # @param action [String] Name of action
  def initialize(args, action)
    @action = action
    if args[:run_mode] == 'NORMAL'
      @phase = 'SHUTDOWN'
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
    File.write('/tmp/AfterAction', :ACTION_AFTER_TEST)
    update_state('ACTION_AFTER_TEST', COMPLETE)
    deactivate(@action)
  end

  private

  # States for this action
  def states
    [
        ['0', 'ACTION_AFTER_TEST', 'Action should run during shutdown']
    ]
  end
end