require 'state/support/data_access_sqlite3'

class Action

  include DataAccessSqlite3

  def save_state(action, control)
    execute_sql_statement(
      "insert into state_machine "\
      "(flag, phase, payload, state)"\
      "values"\
      "('#{action.flag}', '#{action.phase}', '#{action.payload}', '#{action.state}');",
      control
    )
  end

  def update_action(action, control)
    execute_sql_statement(
    "update state_machine set "\
    "phase = '#{action.phase}', payload = '#{action.payload}', state = '#{action.state}' "\
    "where flag = '#{action.flag}';",
        control
    )
  end

  def recover_state(action, control)
    rows = execute_sql_query(
      "select phase, payload, state from state_machine where flag = '#{action.flag}'",
      control
    )

    raise("Database corruption? More than one record found for action (#{action.flag})") if
        rows.size > 1

    action.phase = rows.split(',')[0]
    action.payload = rows.split(',')[1]
    action.state = rows.split(',')[2]

  end

end