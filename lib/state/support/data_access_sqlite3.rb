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

    execute_sql_statement("CREATE TABLE state" \
        "(" \
        "    state_id INTEGER PRIMARY KEY," \
        "    status INTEGER DEFAULT 1," \
        "    state_txt CHAR NOT NULL," \
        "    note CHAR" \
        ");".strip,
        control)

    execute_sql_statement("CREATE TABLE state_machine" \
        "(" \
        "state_machine_id INTEGER PRIMARY KEY,"\
        "flag CHAR,"\
        "phase CHAR DEFAULT 'STARTUP',"\
        "payload CHAR,"\
        "state char DEFAULT 'SKIP'"\
        ")".strip ,
        control)
  end

  def delete_db(control)
    File.delete(control[:sqlite3_db]) if File.file? control[:sqlite3_db]
  end
end