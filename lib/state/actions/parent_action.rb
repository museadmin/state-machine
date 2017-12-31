# frozen_string_literal: true

require 'state/support/standing_data'
require 'state/support/action_support'
require 'state/support/data_access_sqlite3'

# Top level parent class for actions
class ParentAction
  include DataAccessSqlite3
  include ActionSupport

  attr_accessor :flag, :phase, :activation, :payload, :logger

  # Super init called by all action objects
  # @param logger [Logger] The logger object
  def initialize(logger)
    @logger = logger
    save_action(self)
    insert_states(states) unless states.nil?
  end

  # Child action queries if it is active
  def active
    (@phase == query_run_phase_state || @phase == 'ALL') &&
      query_activation(@flag) == 'ACT'
  end

  # Set an action to active
  # @param args [Hash] At least the flag of the target action
  def activate(args)
    args[:activation] = 'ACT'
    update_action_where(args)
  end

  # Deactivate an action.
  # @param flag [String] The target action's flag
  def deactivate(flag)
    update_action_where(activation: 'SKIP', flag: flag)
  end

  # Convenience method for initiating a shutdown
  def normal_shutdown
    activate(flag: 'SYS_NORMAL_SHUTDOWN')
  end
end