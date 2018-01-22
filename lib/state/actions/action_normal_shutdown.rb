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
    # TODO: Add after and finally hooks. Search for them here and action if found
    # TODO if found don't break out until they have finished. Timeout??
    update_option_group_run_phase_state('SHUTDOWN')

    # First take care of any after hooks
    activate_hooks('AFTER')
    return unless hooks_completed('AFTER')

    # Then take care of any finally hooks
    activate_hooks'FINALLY'
    return unless hooks_completed('FINALLY')

    # Then stop
    update_state('READY_TO_RUN', SKIP)
    update_state('BREAKOUT', ACT)
  end

  private

  def states
    [
        ['0', 'SHUTDOWN', 'We are shutting down normally']
    ]
  end

  # If we have after hooks, activate them
  def activate_hooks(hook)
    execute_sql_query(
      "select state_flag from state \n " \
      "where state_flag like '%#{hook}_%' \n" \
      "and status = '#{NOT_RUN}';"
    ).each do |result|
      activate(action: result[0])
    end
    define_singleton_method(:activate_after_hooks) {}
  end

  # If we have finally hooks, activate them
  def activate_finally_hooks
    results = execute_sql_query(
        "select state_flag from state \n " \
      "where state_flag like '%FINALLY_%' \n" \
      "and status = '#{NOT_RUN}';"
    )
    results[0].each do |state_flag|
      activate(action: state_flag)
    end
    define_singleton_method(:activate_finally_hooks) {}
  end

  # Check we don't have any un-actioned hooks
  def hooks_completed(hook)
    execute_sql_query(
        "select status from state where state_flag like '%#{hook}_%'"
    ).each do |status|
      return false if status[0].to_i.zero?
    end
    true
  end
end
