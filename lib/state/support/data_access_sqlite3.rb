require 'sqlite3'

module DataAccessSqlite3

  def execute_sql_query(sql_query, control)
    rows = []
    SQLite3::Database.new( control[:sqlite3_db] ) do |db|
      db.execute( "#{sql_query}" ) do |row|
        rows.push row
      end
    end
    rows
  end

  def execute_sql_statement(sql_statement, control)
    SQLite3::Database.new( control[:sqlite3_db] ) do |db|
      db.execute( "#{sql_statement}" )
    end
  end

  def create_tables(control)

    execute_sql_statement("CREATE TABLE state\n" +
        "(\n"  +
        "    state_id INTEGER PRIMARY KEY,\n" +
        "    status INTEGER DEFAULT 1, -- True (1) or False (0)\n" +
        "    state_flag CHAR NOT NULL, -- Textual flag\n" +
        "    note CHAR                 -- Comment explaining what this state is for\n" +
        ");".strip,
        control)

    execute_sql_statement("CREATE TABLE state_machine\n" +
        "(\n" +
        "state_machine_id INTEGER PRIMARY KEY,\n" +
        "flag CHAR,                    -- The textual flag. e.g. PROCESS_NORMAL_SHUTDOWN\n" +
        "phase CHAR DEFAULT 'STARTUP', -- The run phase\n" +
        "payload CHAR,                 -- Any payload sent via msg for action\n" +
        "activation char DEFAULT 'SKIP'     -- The activation. ACT or SKIP\n" +
        ")".strip ,
        control)
  end

  def insert_state(state, control)

    execute_sql_statement(
        "insert into state \n" +
            "(status, state_flag, note)\n" +
            "values\n" +
            "('#{state[0]}', '#{state[1]}', '#{state[2]}');",
        control)

  end

  def insert_states(states, control)
    states.each do  |state|
      insert_state(state, control)
    end
  end

  def delete_db(control)
    File.delete(control[:sqlite3_db]) if File.file? control[:sqlite3_db]
  end

  def update_state(flag, value, control)

    raise "Unexpected value for state (#{value})" if value != 0 and value != 1

    execute_sql_statement(
        "update state set \n" +
            "status = '#{value}' \n" +
            "where state_flag = '#{flag}';",
        control
    )

  end

  def query_state(flag, control)
    execute_sql_query(
        "select status from state \n" +
            "where state_flag = '#{flag}';",
        control
    )
  end

end