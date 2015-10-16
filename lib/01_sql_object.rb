require_relative 'db_connection'
require 'active_support/inflector'
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
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
