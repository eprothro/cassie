module Cassie::Queries::Statement
  #
  #
  #    relation "username = ?", :username
  #    relation :username, :eq
  #    relation :username, :eq, allow_blank: false
  #    relation :username, :eq, source: :method
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
                :operation

    def initialize(identifier, op_type, opts={})
      if String === identifier
        #  custom relation is being defined:
        #
        #  `relation "username = ?", :username`
        @cql = identifier
        @term_method = operation
      else
        @identifier = identifier
        @op_type = op_type.to_sym
        @term_method = opts[:value] || identifier
      end
    end

    def to_cql
      cql
    end

    def term(term_object)
      term_object.send term_method
    end

    def term_method
      @term_method
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