require 'sqlite3'

module DataAccessSqlite3

  attr_accessor :db_file

  def initialize
    @db_file = nil
  end

  def set_db_file(db_file)
    @db_file = db_file
  end

  def execute_sql_query(sql_query)
    rows = []
    SQLite3::Database.new( @db_file ) do |db|
      db.execute( "#{sql_query}" ) do |row|
        rows.push row
      end
    end
    rows
  end

  def execute_sql_statement(sql_statement)
    SQLite3::Database.new( @db_file ) do |db|
      db.execute( "#{sql_statement}" )
    end
  end

  def create_tables

    execute_sql_statement("CREATE TABLE state\n" +
        "(\n"  +
        "   state_id INTEGER PRIMARY KEY,\n" +
        "   status INTEGER DEFAULT 1, -- True (1) or False (0)\n" +
        "   state_flag CHAR NOT NULL, -- Textual flag\n" +
        "   note CHAR                 -- Comment explaining what this state is for\n" +
        ");".strip)

    execute_sql_statement("CREATE TABLE state_machine\n" +
        "(\n" +
        "   state_machine_id INTEGER PRIMARY KEY,\n" +
        "   flag CHAR,                    -- The textual flag. e.g. PROCESS_NORMAL_SHUTDOWN\n" +
        "   phase CHAR DEFAULT 'STARTUP', -- The run phase\n" +
        "   payload CHAR,                 -- Any payload sent via msg for action\n" +
        "   activation char DEFAULT 'SKIP'     -- The activation. ACT or SKIP\n" +
        ")".strip)

    execute_sql_statement("CREATE TABLE properties\n" +
        "(\n" +
        "   property CHAR PRIMARY KEY,    -- A property\n" +
        "   value CHAR                    -- The value of the property\n" +
        ")".strip)
  end

  def insert_state(state)

    execute_sql_statement(
        "insert into state \n" +
            "(status, state_flag, note)\n" +
            "values\n" +
            "('#{state[0]}', '#{state[1]}', '#{state[2]}');")

  end

  def insert_states(states)
    states.each do  |state|
      insert_state(state)
    end
  end

  def delete_db
    File.delete(@db_file) if File.file? @db_file
  end

  def update_state(flag, value)

    raise "Unexpected value for state (#{value})" if value != 0 and value != 1

    execute_sql_statement(
        "update state set \n" +
        "status = '#{value}' \n" +
        "where state_flag = '#{flag}';"
    )

  end

  def query_state(flag)
    execute_sql_query(
        "select status from state \n" +
            "where state_flag = '#{flag}';"
    )
  end

  def insert_property(property, value)

    execute_sql_statement(
        "insert into properties \n" +
            "(property, value)\n" +
            "values\n" +
            "('#{property}', '#{value}');"
    )

  end

  def query_property(property)
    execute_sql_query(
        "select value from properties \n" +
            "where property = '#{property}';"
    )[0][0]
  end

  def update_property(property, value)

    execute_sql_statement(
        "update properties set \n" +
            "value = '#{value}' \n" +
            "where property = '#{property}';"
    )

  end

end