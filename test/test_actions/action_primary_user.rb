# frozen_string_literal: true

require 'state/actions/parent_action'

# A test action
class ActionPrimaryUser < ParentAction
  # Instantiate the action
  # @param args [Hash] Required parameters for the action
  # run_mode [Symbol] Either NORMAL or RECOVER
  # sqlite3_db [Symbol] Path to the main control DB
  # logger [Symbol] The logger object for logging
  def initialize(args, flag)
    @flag = flag
    if args[:run_mode] == 'NORMAL'
      @phase = 'RUNNING'
      @activation = 'ACT'
      @payload = 'NULL'
      super(args[:sqlite3_db], args[:logger])
    else
      recover_action(self)
    end
  end

  # Do the work for this action
  def execute
    return unless active
    activate(flag: 'ACTION_SECONDARY_USER')
    deactivate(@flag)
  end

  private

  # States for this action
  def states
    [
        ['0', 'PRIMARY_TEST_STATE', 'A test state for the unit tests']
    ]
  end
end