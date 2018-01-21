# frozen_string_literal: true

require 'state/support/standing_data'
require 'state/support/action_support'
require 'state/support/data_access_sqlite3'
require 'state/support/constants'

# Top level parent class for actions
class ParentAction
  include DataAccessSqlite3
  include ActionSupport

  attr_accessor :action, :phase, :activation, :payload, :logger

  # Super init called by all action objects
  # @param logger [Logger] The logger object
  def initialize(logger)
    @logger = logger
    save_action(self)
    insert_states(states) unless states.nil?
  end

  # Retrieve the payload from the db for this action
  def this_payload(action)
    query_payload(action)
  end

  # Child action queries if it is active
  def active
    if (@phase == query_run_phase_state || @phase == 'ALL') &&
      query_activation(@action) == ACT
      @logger.debug("Action #{action} is active, executing")
      return true
    end
    false
  end

  # Set an action to active
  # @param args [Hash] At least the flag of the target action
  def activate(args)
    args[:activation] = ACT
    update_action_where(args)
  end

  # Deactivate an action.
  # @param flag [String] The target action's flag
  def deactivate(action)
    update_action_where(activation: SKIP, action: action)
  end

  # Convenience method for initiating a shutdown
  def normal_shutdown
    activate(action: 'SYS_NORMAL_SHUTDOWN')
  end
end