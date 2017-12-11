require 'state/support/data_access_sqlite3'

class Action

  include DataAccessSqlite3

  # Add a record to the control DB for this child action
  def save_action(action, control)
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

  # TODO recover_state()

end