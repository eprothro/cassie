module Cassie::Statements::Statement
  #
  #
  #    relation :username, :eq
  #    relation :username, :eq, value: :method
  #    relation :phone, :in
  #    relation :user_id, :gteq, term: "minTimeuuid('2013-02-02 10:00+0000')"
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

    attr_reader :source,
                :identifier,
                :operation,
                :value,
                :enabled,
                :term


    def initialize(source, identifier, op_type, value_method, opts={})
      @source = source
      @identifier = identifier
      @operation = OPERATIONS[op_type.to_sym]
      @value = source.send(value_method)
      @enabled = opts.has_key?(:if) ? source_eval(opts[:if]) : true
      @term = opts.has_key?(:term) ? source_eval(opts[:term]) : "?"
    end

    def enabled?
      !!enabled
    end

    def argument?
      enabled? && positional?
    end

    def argument
      value if argument?
    end

    def positional?
      term.to_s.include?("?")
    end

    def to_cql
      return nil unless enabled?
      "#{identifier} #{operation} #{term}"
    end

    private

    def source_eval(value, src=source)
      case value
      when Symbol
        src.send(value)
      else
        value
      end
    end
  end
end