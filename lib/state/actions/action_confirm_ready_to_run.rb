# frozen_string_literal: true

require 'state/actions/parent_action'

# Check we're ready to run and then change state to
# READY_TO_RUN and run phase from STARTUP to RUNNING
class ActionConfirmReadyToRun < ParentAction
  # Instantiate the action
  # @param args [Hash] Required parameters for the action
  # @action [String] Name of action
  def initialize(args, action)
    @action = action
    if args[:run_mode] == 'NORMAL'
      @phase = 'ALL'
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
    return unless initialization_completed
    update_run_phase_state('RUNNING')
    update_state('READY_TO_RUN', 1)
  end

  private

  # States for this action
  def states
    [
        ['0', 'READY_TO_RUN', 'We are ready to run']
    ]
  end

  # Any action states that begin their name with INIT_ must set
  # status field to 1 before we are considered to be ready to run
  # Enables third party action packs to define actions as a part
  # of the startup phase.
  def initialization_completed
    completed = true
    init = execute_sql_query(
        "select status from state where state_flag like 'INIT_%'"
    )
    return completed if init.size.zero?
    init.each do |status|
      completed = false if status[0].to_i.zero?
    end
    completed
  end
end
