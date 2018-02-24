# frozen_string_literal: true

require 'state/support/constants'
require 'sqlite3'
require 'thread'

# Database access methods
module DataAccessSqlite3

  @@db_lock = nil
  @@sqlite3_db = nil

  # Execute a generic sql query and return an array of the results
  # @param sql_query [String] The SQL query to run
  # @return [String] An array of string arrays
  def execute_sql_query(sql_query)

    rows = []
    SQLite3::Database.new(@@sqlite3_db) do |db|
      db.execute(sql_query) do |row|
        rows.push row
      end
    end
    rows
  rescue SQLite3::Exception => e
    @logger.error(
      'SQL Error in execute_sql_query (' + e.message + ')' \
      'SQL - (' + sql_query + ')'
    )
    raise 'SQL Error in execute_sql_query (' + e.message + ')'
  end

  # Execute a sql statement. e.g. an update or insert
  # @param sql_statement [String] The SQL statement to execute
  def execute_sql_statement(sql_statement)
    @@db_lock.synchronize {
      begin
        SQLite3::Database.new(@@sqlite3_db) do |db|
          db.execute(sql_statement)
        end
      rescue SQLite3::Exception => e
        @logger.error(
          'SQL Error in execute_sql_statement (' + e.message + ')' +
          'SQL - (' + sql_statement + ')'
        )
        raise 'SQL Error in execute_sql_statement (' + e.message + ')'
      end
    }
  end

  # Create the default tables in the control DB
  def create_tables
    execute_sql_statement(<<-CREATE_STATE
      CREATE TABLE state (
       state_id INTEGER PRIMARY KEY, \n
        status INTEGER DEFAULT 1, -- True (1) or False (0) \n
         state_flag CHAR NOT NULL, -- Textual flag \n
          note CHAR -- Comment explaining what this state is for \n
      );
    CREATE_STATE
                         )

    execute_sql_statement(<<-CREATE_SM
        CREATE TABLE state_machine (
        state_machine_id INTEGER PRIMARY KEY,\n
        action CHAR, -- The textual name. e.g. PROCESS_NORMAL_SHUTDOWN\n
        phase CHAR DEFAULT 'STARTUP', -- The run phase\n
        payload CHAR, -- Any payload sent via msg for action\n
        activation INTEGER DEFAULT 0 -- The activation. ACT = 1 or SKIP = 0\n
      );
    CREATE_SM
                         )

    execute_sql_statement(<<-CREATE_PROPS
        CREATE TABLE properties (
        property CHAR PRIMARY KEY, -- A property\n
        value CHAR -- The value of the property\n
      );
    CREATE_PROPS
                         )
  end

  def query_payload(action)
    execute_sql_query(<<-SELECT_PAYLOAD
        select payload from state_machine
         where action = '#{action}';
    SELECT_PAYLOAD
                     )[0][0]
  end

  # Insert a state on behalf of an action
  # @param state [Array] An array of strings
  def insert_state(state)
    execute_sql_statement(<<-INSERT_STATE
        insert into state
         (status, state_flag, note)
          values
           ('#{state[0]}', '#{state[1]}', '#{state[2]}');
    INSERT_STATE
                         )
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
    File.delete(@@sqlite3_db) if File.file? @@sqlite3_db
  end

  # Update the value of a state in the state table
  # @param state_flag [String] The target state  to update
  # @param value [Integer] 0 unset or 1 set
  def update_state(state_flag, value)
    raise "Unexpected value for state (#{value})" if value != 0 && value != 1

    execute_sql_statement(<<-UPDATE_STATE
        update state set
         status = '#{value}'
          where state_flag = '#{state_flag}';
    UPDATE_STATE
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
    execute_sql_statement(<<-INSERT_PROP
        insert into properties
         (property, value)
          values
           ('#{property}', '#{value}');
    INSERT_PROP
                         )
  end

  # Return the value fo a property in the properties table
  # @param property [String] The name of the property
  def query_property(property)
    execute_sql_query(<<-QUERY_PROP
        select value from properties
         where property = '#{property}';
    QUERY_PROP
                     )[0][0]
  end

  # Update a property in the properties table
  # @param property [String] The name of the property
  # @param value [Object] The value to set
  def update_property(property, value)
    execute_sql_statement(<<-UPDATE_PROP
        update properties set
         value = '#{value}'
          where property = '#{property}';
    UPDATE_PROP
                         )
  end

  # Save the state of an action that has just been loaded
  # @param action [Acton] An action object
  def save_action(action)
    execute_sql_statement(<<-SAVE_ACTION
        insert into state_machine
         (action, phase, payload, activation)
          values
           ('#{@action}',
            '#{action.phase}',
             '#{action.payload}',
              '#{action.activation}');
    SAVE_ACTION
                         )
  end

  # Update an action when it has changed state.
  # e.g. New payload or activated
  # @param action [Hash] Set of params for update
  def update_action(action)
    execute_sql_statement(<<-UPDATE_ACTION
        update state_machine set
         phase = '#{action.phase}',
          payload = '#{action.payload}',
           activation = '#{action.activation}'
            where action = '#{action.action}';
    UPDATE_ACTION
                         )
  end

  # Recover an action from the database.
  # Will be used in RECOVER mode
  # @param action [Action] Instance of action trying to recover itself
  def recover_action(action)
    rows = execute_sql_query(<<-RECOVER
      select phase, payload, activation
        from state_machine
         where action = '#{action.action}';
    RECOVER
                            )
    raise("More than one record found for action (#{action.flag})") if
        rows.size > 1
    action.phase = rows.split(',')[0]
    action.payload = rows.split(',')[1]
    action.activation = rows.split(',')[2]
  end

  # Determine if an action is currently active
  # @param action [String] The action
  def query_activation(action)
    execute_sql_query(<<-QUERY_ACTIVIATION
      select activation from state_machine
       where action = '#{action}';
    QUERY_ACTIVIATION
                     )[0][0]
  end

  # Update an action when it has changed state.
  # e.g. New payload or activated
  # @param args [Hash] Optional parameters for update
  def update_action_where(args)
    ph = update_phase(args)
    pa = update_payload(args)
    ac = update_activation(args)
    wh = "where action = '#{args[:action]}';"
    sql = 'update state_machine set ' + ph + pa + ac + wh
    execute_sql_statement(sql)
  end

  private

  def update_phase(args)
    args[:phase].nil? ? '' : "phase = '#{args[:phase]}',"
  end

  def update_payload(args)
    args[:payload].nil? ? '' : "payload = '#{args[:payload]}',"
  end

  def update_activation(args)
    args[:activation].nil? ? '' : " activation = '#{args[:activation]}' "
  end
end