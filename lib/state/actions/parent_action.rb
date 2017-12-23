require 'state/support/data_access_sqlite3'

class ParentAction

  include DataAccessSqlite3

  attr_accessor :flag, :phase, :activation, :payload

  def initialize(control)
    set_db_file(control[:sqlite3_db])
    save_action(self)
    insert_states(@states) unless @states.nil?
  end

  def active
    (@phase == query_property('phase') || @phase == 'ALL') && @activation == 'ACT'
  end

  def save_action(action)
    execute_sql_statement(
      "insert into state_machine \n" +
      "(flag, phase, payload, activation)\n" +
      "values\n" +
      "('#{action.flag}', '#{action.phase}', '#{action.payload}', '#{action.activation}');"
    )
  end

  def update_action(action)
    execute_sql_statement(
    "update state_machine set \n" +
    "phase = '#{action.phase}', payload = '#{action.payload}', activation = '#{action.activation}' \n" +
    "where flag = '#{action.flag}';"
    )
  end

  def recover_action(action)
    rows = execute_sql_query(
      "select phase, payload, activation from state_machine where flag = '#{action.flag}'"
    )

    raise("Database corruption? More than one record found for action (#{action.flag})") if
        rows.size > 1

    action.phase = rows.split(',')[0]
    action.payload = rows.split(',')[1]
    action.activation = rows.split(',')[2]

  end

end