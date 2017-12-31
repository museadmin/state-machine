# frozen_string_literal: true

require 'state/actions/parent_action'

# Perform an emergency shutdown
class ActionEmergencyShutdown < ParentAction
  # Instantiate the action
  # @param args [Hash] Required parameters for the action
  # run_mode [Symbol] Either NORMAL or RECOVER
  # sqlite3_db [Symbol] Path to the main control DB
  # logger [Symbol] The logger object for logging
  def initialize(args, flag)
    @flag = flag
    if args[:run_mode] == 'NORMAL'
      @phase = 'ALL'
      @activation = 'SKIP'
      @payload = 'NULL'
      super(args[:logger])
    else
      recover_action(self)
    end
  end

  # Perform the work
  def execute
    return unless active
    update_state('EMERGENCY_SHUTDOWN', 1)
    update_state('RUNNING', 0)
    update_state('READY_TO_RUN', 0)
    update_property('phase', 'SHUTDOWN')
    update_state('BREAKOUT', 1)
  end

  private

  # States for this action
  def states
    [
        ['0', 'EMERGENCY_SHUTDOWN',
         'State machine has a bug, cannot be trusted']
    ]
  end
end
