# frozen_string_literal: true

require 'sqlite3'

# Database access methods
module DataAccessSqlite3
  def execute_sql_query(sql_query)
    rows = []
    SQLite3::Database.new(@sqlite3_db) do |db|
      db.execute(sql_query) do |row|
        rows.push row
      end
    end
    rows
  end

  def execute_sql_statement(sql_statement)
    SQLite3::Database.new(@sqlite3_db) do |db|
      db.execute(sql_statement)
    end
  end

  def create_tables
    execute_sql_statement("CREATE TABLE state\n" \
      "(\n"  \
      "   state_id INTEGER PRIMARY KEY,\n" \
      "   status INTEGER DEFAULT 1, -- True (1) or False (0)\n" \
      "   state_flag CHAR NOT NULL, -- Textual flag\n" \
      "   note CHAR -- Comment explaining what this state is for\n" \
      ");".strip)

    execute_sql_statement("CREATE TABLE state_machine\n" \
      "(\n" \
      "   state_machine_id INTEGER PRIMARY KEY,\n" \
      "   flag CHAR, -- The textual flag. e.g. PROCESS_NORMAL_SHUTDOWN\n" \
      "   phase CHAR DEFAULT 'STARTUP', -- The run phase\n" \
      "   payload CHAR, -- Any payload sent via msg for action\n" \
      "   activation char DEFAULT 'SKIP' -- The activation. ACT or SKIP\n" \
      ")".strip)

    execute_sql_statement("CREATE TABLE properties\n" \
      "(\n" \
      "   property CHAR PRIMARY KEY, -- A property\n" \
      "   value CHAR -- The value of the property\n" \
      ")".strip)
  end

  def insert_state(state)
    execute_sql_statement("insert into state \n" \
      "(status, state_flag, note)\n" \
      "values\n" \
      "('#{state[0]}', '#{state[1]}', '#{state[2]}');")
  end

  def insert_states(states)
    states.each do |state|
      insert_state(state)
    end
  end

  def delete_db
    File.delete(@sqlite3_db) if File.file? @sqlite3_db
  end

  def update_state(flag, value)
    raise "Unexpected value for state (#{value})" if value != 0 && value != 1

    execute_sql_statement(
      "update state set \n" \
      "status = '#{value}' \n" \
      "where state_flag = '#{flag}';"
    )
  end

  def query_state(flag)
    execute_sql_query(
      "select status from state \n" \
      "where state_flag = '#{flag}';"
    )[0][0]
  end

  def insert_property(property, value)
    execute_sql_statement(
      "insert into properties \n" \
      "(property, value)\n" \
      "values\n" \
      "('#{property}', '#{value}');"
    )
  end

  def query_property(property)
    execute_sql_query(
      "select value from properties \n" \
      "where property = '#{property}';"
    )[0][0]
  end

  def update_property(property, value)
    execute_sql_statement(
      "update properties set \n" \
      "value = '#{value}' \n" \
      "where property = '#{property}';"
    )
  end

  def save_action(action)
    execute_sql_statement(
      "insert into state_machine \n" \
      "(flag, phase, payload, activation)\n" \
      "values\n" \
      "('#{@flag}',\n" \
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

  def update_action_where(phase, payload, activation, flag)
    ph = phase.nil? ? '' : "phase = '#{phase}',"
    pa = payload.nil? ? '' : "payload = '#{payload}',"
    ac = activation.nil? ? '' : " activation = '#{activation}' "
    wh = "where flag = '#{flag}';"
    sql = 'update state_machine set ' + ph + pa + ac + wh
    execute_sql_statement(sql)
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

  def query_activation(flag)
    execute_sql_query(
      "select activation from state_machine \n" \
      "where flag = '#{flag}';"
    )[0][0]
  end

end