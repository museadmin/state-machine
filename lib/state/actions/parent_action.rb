# frozen_string_literal: true

require 'state/support/standing_data'
require 'state/support/action_support'
require 'state/support/data_access_sqlite3'

# Top level parent class for actions
class ParentAction
  include DataAccessSqlite3
  include ActionSupport

  attr_accessor :flag, :phase, :activation, :payload, :logger

  def initialize(sqlite3_db, logger)
    @sqlite3_db = sqlite3_db
    @logger = logger
    save_action(self)
    insert_states(states) unless states.nil?
  end

  def active
    (@phase == query_run_phase_state || @phase == 'ALL') &&
      query_activation(@flag) == 'ACT'
  end

  def activate(flag)
    update_action_where(nil, nil, 'ACT', flag)
  end

  def deactivate(flag)
    update_action_where(nil, nil, 'SKIP', flag)
  end

  def normal_shutdown
    activate('SYS_NORMAL_SHUTDOWN')
  end
end