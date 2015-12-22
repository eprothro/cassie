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