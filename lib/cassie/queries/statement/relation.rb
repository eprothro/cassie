# for pluralization
require 'active_support/core_ext/string'

module Cassie::Queries::Statement
  #
  #
  #    relation "username = ?", value: :username
  #    relation :username, :eq
  #    relation :username, :eq, value: :method
  #    relation :phone, :in
  class Relation
    # https://cassandra.apache.org/doc/cql3/CQL.html#selectStmt

    OPERATIONS = {
                  eq: "=",
                  lt: "<",
                  lteq: "<=",
                  gt: ">",
                  gteq: ">=",
                  in: "IN",
                  contains: "CONTAINS",
                  contains_key: "CONTAINS KEY",
    }

    attr_reader :identifier,
                :op_type

    def initialize(identifier, op_type, opts={})
      if Hash === op_type
        #  custom relation is being defined:
        #  `relation "username = ?", value: :username`

        # swap the 2nd arg that sucked in options hash
        # to keep consistent feeling interface
        opts.merge!(op_type)

        @cql = identifier
        @custom = true
      else
        @identifier = identifier
        @op_type = op_type.to_sym
      end
    end

    def custom?
      !!@custom
    end

    def to_cql
      cql
    end

    def multiple_term?
      op_type == :in
    end

    def implied_value_method
      method = if multiple_term?
        identifier.to_s.pluralize
      else
        identifier
      end

      method.to_sym
    end

    protected

    def cql
      # we always generate bound statements
      @cql ||= "#{identifier} #{OPERATIONS[op_type]} ?"
    end

    def op_type
      @op_type
    end
  end
end