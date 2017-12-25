# frozen_string_literal: true

require 'state/support/data_access_sqlite3'

# Top level parent class for actions
class ParentAction
  include DataAccessSqlite3

  attr_accessor :flag, :phase, :activation, :payload

  def initialize(control)
    @db_file = control[:sqlite3_db]
    save_action(self, @flag)
    insert_states(states) unless states.nil?
  end

  def active
    (@phase == query_property('phase') || @phase == 'ALL') &&
      @activation == 'ACT'
  end

  def save_action(action, flag)
    execute_sql_statement(
      "insert into state_machine \n" \
      "(flag, phase, payload, activation)\n" \
      "values\n" \
      "('#{flag}',\n" \
      " '#{action.phase}',\n" \
      " '#{action.payload}',\n" \
      " '#{action.activation}');"
    )
  end

  def update_action(action)
    execute_sql_statement(
      "update state_machine set \n" \
      "phase = '#{action.phase}',\n" \
      " payload = '#{action.payload}',\n" \
      " activation = '#{action.activation}' \n" \
      "where flag = '#{action.flag}';"
    )
  end

  def recover_action(action)
    rows = execute_sql_query(
      "select phase, payload, activation\n" \
      " from state_machine\n" \
      " where flag = '#{action.flag}'"
    )
    raise("More than one record found for action (#{action.flag})") if
        rows.size > 1
    action.phase = rows.split(',')[0]
    action.payload = rows.split(',')[1]
    action.activation = rows.split(',')[2]
  end

  def normal_shutdown(control)
    control[:actions]['SYS_NORMAL_SHUTDOWN'].activation = 'ACT'
  end
end