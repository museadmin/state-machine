# frozen_string_literal: true

require 'state/actions/parent_action'

# Check we're ready to run and then change state
class ActionConfirmReadyToRun < ParentAction
  def initialize(args, flag)
    @flag = flag
    if args[:run_mode] == 'NORMAL'
      @phase = 'ALL'
      @activation = 'ACT'
      @payload = 'NULL'
      super(args[:sqlite3_db], args[:logger])
    else
      recover_action(self)
    end
  end

  def states
    [
      ['0', 'READY_TO_RUN', 'We are ready to run']
    ]
  end

  def execute
    return unless active
    # TODO: Find a way to define the run state dynamically
    return unless initialization_completed
    update_run_phase_state('RUNNING')
    update_state('READY_TO_RUN', 1)
  end

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
