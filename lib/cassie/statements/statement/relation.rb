# for pluralization
require 'active_support/core_ext/string'

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
                :opts,
                :identifier,
                :op_type,
                :value_method

    def initialize(identifier, op_type, opts={})
      @identifier = identifier
      @op_type = op_type.to_sym
      opts[:if] = opts.fetch(:if, true)
      opts[:term] = opts.fetch(:term, "?")
      opts[:value] = opts.fetch(:value, implied_value_method)
      @opts = opts
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

    def value_method
      opts[:value]
    end

    def bind(source)
      @source = source
    end

    def enabled?
      !!eval_opt(opts[:if])
    end

    def term
      eval_opt(opts[:term])
    end

    def operation
      OPERATIONS[op_type]
    end

    def argument
      eval_opt(value_method)
    end

    def positional?
      term.to_s.include?("?")
    end

    protected

    def eval_opt(value)
      case value
      when Symbol
        source.send(value)
      else
        value
      end
    end
  end
end