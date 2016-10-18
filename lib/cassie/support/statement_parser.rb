module Cassie::Support
  class StatementParser
    attr_reader :statement

    def initialize(statement)
      @statement = statement
    end

    def bound_cql
      statement.cql
    end

    def params
      statement.params
    end

    def params_types
      statement.params_types
    end

    def to_cql
      cql = bound_cql.dup

      params_types.map.with_index do |type, i|
        cassandra_param = type.new(params[i])
        quoted_val = if QUOTED_TYPES.include? type.kind
          "'#{cassandra_param.to_s}'"
        else
          cassandra_param.to_s
        end

        cql.sub!("?", quoted_val)
      end
      cql
    end

    protected

    QUOTED_TYPES = [:date, :time, :text, :timestamp, :inet, :ascii].freeze
  end
end