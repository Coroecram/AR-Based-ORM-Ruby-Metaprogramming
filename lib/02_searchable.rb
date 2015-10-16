require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params = {})
    keys = []
    params.each do |k, _|
      keys << k
    end
    where_line = keys.join(" = ? AND ") + " = ?"
    p params.values
    result = DBConnection.execute(<<-SQL, *params.values)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{where_line}
    SQL
    return result if result.empty?
    parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
