require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    columns = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL

    columns.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column_name|
      define_method("#{column_name}=".to_sym) do |value|
        attributes[column_name] = value
      end

      define_method(column_name) { attributes[column_name] }
    end
  end

  def self.table_name=(table_name = self.class.to_s)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.downcase.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    new_instances = []
    species = results[0].include?("owner_id") ? Cat : Human
    results.each do |entry|
      new_instances << species.new(entry)
    end
    new_instances
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = #{id}
    SQL

    return nil if result.empty?
    parse_all(result).first
  end

  def initialize(params = {})
      params.each do |attr_name, value|
        attr_sym = attr_name.to_sym
        raise "unknown attribute: '#{attr_name}'" unless self.class::columns.include?(attr_sym)
        send("#{attr_sym}=".to_sym, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    values = self.class.columns.map { |symbol| send(symbol) }
  end

  def insert
    col_names = self.class.columns[1..-1].join(", ")
    question_marks = []
    insert_length = attribute_values.length
    (insert_length-1).times { question_marks << "?" }
    DBConnection.execute(<<-SQL, *attribute_values[1..-1])
    INSERT INTO #{self.class.table_name}
      (#{col_names})
    VALUES
      (#{question_marks.join(", ")})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns[1..-1].reverse.join(" = ?, ")
    col_names = col_names + " = ?"
    DBConnection.execute(<<-SQL, *(attribute_values.reverse))
    UPDATE
       #{self.class.table_name}
    SET
      #{col_names}
    WHERE
      id = ?
    SQL
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end
end
