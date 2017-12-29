# frozen_string_literal: true

require 'sqlite3'

# Database access methods
module DataAccessSqlite3
  # Execute a generic sql query and return an array of the results
  # @param sql_query [String] The SQL query to run
  # @return [String] An array of string arrays
  def execute_sql_query(sql_query)
    rows = []
    SQLite3::Database.new(@sqlite3_db) do |db|
      db.execute(sql_query) do |row|
        rows.push row
      end
    end
    rows
  end

  # Execute a sql statement. e.g. an update or insert
  # @param sql_statement [String] The SQL statement to execute
  def execute_sql_statement(sql_statement)
    SQLite3::Database.new(@sqlite3_db) do |db|
      db.execute(sql_statement)
    end
  end

  # Create the default tables in the control DB
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

  # Insert a state on behalf of an action
  # @param state [Array] An array of strings
  def insert_state(state)
    execute_sql_statement("insert into state \n" \
      "(status, state_flag, note)\n" \
      "values\n" \
      "('#{state[0]}', '#{state[1]}', '#{state[2]}');")
  end

  # Iterate over an array of string arrays and enter
  # the values into the state table in the DB
  # @param states [Array] An array of string arrays
  def insert_states(states)
    states.each do |state|
      insert_state(state)
    end
  end

  # Delete the control DB if existing prior to creating a new one.
  def delete_db
    File.delete(@sqlite3_db) if File.file? @sqlite3_db
  end

  # Update the value of a state in the state table
  # @param state_flag [String] The target state  to update
  # @param value [Integer] 0 unset or 1 set
  def update_state(state_flag, value)
    raise "Unexpected value for state (#{value})" if value != 0 && value != 1

    execute_sql_statement(
      "update state set \n" \
      "status = '#{value}' \n" \
      "where state_flag = '#{state_flag}';"
    )
  end

  # Return the value of a state
  # @param state_flag [String] The target state to query
  def query_state(state_flag)
    execute_sql_query(
      "select status from state \n" \
      "where state_flag = '#{state_flag}';"
    )[0][0]
  end

  # Insert a property into the properties table
  # @param property [String] Name of the property
  # @param value [Object] The value of the property
  def insert_property(property, value)
    execute_sql_statement(
      "insert into properties \n" \
      "(property, value)\n" \
      "values\n" \
      "('#{property}', '#{value}');"
    )
  end

  # Return the value fo a property in the properties table
  # @param property [String] The name of the property
  def query_property(property)
    execute_sql_query(
      "select value from properties \n" \
      "where property = '#{property}';"
    )[0][0]
  end

  # Update a property in the properties table
  # @param property [String] The name of the property
  # @param value [Object] The value to set
  def update_property(property, value)
    execute_sql_statement(
      "update properties set \n" \
      "value = '#{value}' \n" \
      "where property = '#{property}';"
    )
  end

  # Save the state of an action that has just been loaded
  # @param action [Acton] An action object
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

  # Update an action when it has changed state.
  # e.g. New payload or activated
  # @param action [Hash] Set of params for update
  def update_action(action)
    execute_sql_statement(
      "update state_machine set \n" \
      "phase = '#{action.phase}',\n" \
      " payload = '#{action.payload}',\n" \
      " activation = '#{action.activation}' \n" \
      "where flag = '#{action.flag}';"
    )
  end

  # Update an action when it has changed state.
  # e.g. New payload or activated
  # @param args [Hash] Optional parameters for update
  def update_action_where(args)
    ph = args[:phase].nil? ? '' : "phase = '#{args[:phase]}',"
    pa = args[:payload].nil? ? '' : "payload = '#{args[:payload]}',"
    ac = args[:activation].nil? ? '' : " activation = '#{args[:activation]}' "
    wh = "where flag = '#{args[:flag]}';"
    sql = 'update state_machine set ' + ph + pa + ac + wh
    execute_sql_statement(sql)
  end

  # Recover an action form the database.
  # Will be used in RECOVER mode
  # @param action [Action] Instance of action trying to recover itself
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

  # Determine if an action is currently active
  # @param flag [String] The action flag
  def query_activation(flag)
    execute_sql_query(
      "select activation from state_machine \n" \
      "where flag = '#{flag}';"
    )[0][0]
  end

end