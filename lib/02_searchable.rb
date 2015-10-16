require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = #{id}
    SQL
  end
end

class SQLObject
  # Mixin Searchable here...
end
