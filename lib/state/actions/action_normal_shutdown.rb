# frozen_string_literal: true

require 'state/actions/parent_action'

# Action a normal shutdown
class ActionNormalShutdown < ParentAction
  # Instantiate the action
  # @param args [Hash] Required parameters for the action
  # @param action [String] Name of action
  def initialize(args, action)
    @action = action
    if args[:run_mode] == 'NORMAL'
      @phase = 'ALL'
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
    update_run_phase_state('STOPPED')
    update_state('READY_TO_RUN', 0)
    update_state('BREAKOUT', 1)
  end

  private

  def states
    [
        ['0', 'SHUTDOWN', 'We are shutting down normally']
    ]
  end
end
