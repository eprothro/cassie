require 'active_support/core_ext/string/filters'
require_relative 'statement/preparation'
require_relative 'statement/relation'

module Cassie::Queries
  module Statement
    # https://cassandra.apache.org/doc/cql3/CQL.html#selectStmt
    extend ::ActiveSupport::Concern

    included do
      include Preparation

      attr_reader :result

      class << self
        attr_accessor :table,
                      :limit
      end
    end

    module ClassMethods
      def relation(identifier, op, opts={})
        relation = Relation.new(identifier, op, opts)
        opts[:value] ||= identifier.to_sym

        if Symbol === opts[:value]
          define_term_methods(opts[:value])
        end

        relations[relation] = opts
      end

      def where(*args)
        relation(*args)
      end

      def select(table)
        self.table = table
        #TODO: block to add selectors and aliases
      end

      # a select clause is built up of selectors
      def selectors
        @selectors ||= []
      end

      # a where clause is built up of multiple 'relations'
      def relations
        @relations ||= {}
      end

      private

      def define_term_methods(name)
        #TODO: this should probably only raise
        #      if value option was nil and we
        #      are implicilty creating getter/setters.
        if method_defined?(name) || method_defined?("#{name}=")
          raise "accessor or getter already defined for #{name}. Fix the collions by using the `:value` option."
        else
          attr_accessor name
        end
      end
    end

    def table
      self.class.table
    end

    # Executes the statment, populates result
    # returns true or false indicating a successful execution or not
    def execute
      @result = session.execute(statement)
      execution_successful?
    end

    def statement
      Cassandra::Statements::Simple.new(*build_cql_and_bindings)
    end

    def limit
      self.class.limit
    end

    protected

    def build_cql_and_bindings
      where_str, bindings = build_where_and_bindings

      cql = %(
        SELECT #{build_select_clause}
          FROM #{table}
          #{where_str}
          #{build_order_str}
          #{build_limit_str}
      ).squish + ";"

      [cql, bindings]
    end

    # a select clause is built up of selectors
    def selectors
      self.class.selectors
    end

    # a where clause is built up of multiple 'relations'
    def relations
      self.class.relations
    end

    def build_select_clause
      str = if selectors.empty?
        '*'
      else
        selectors.join(', ')
      end
    end

    def build_where_and_bindings
      cql = ""
      bindings = []
      relation_strings = []

      relations.each do |r, opts|
        if eval_if_opt?(opts[:if])
          relation_strings << r.to_cql
          bindings << eval_value_opt(opts[:value])
        end
      end

      cql = "WHERE #{relation_strings.join(' AND ')}" unless bindings.empty?

      [cql , bindings]
    end

    def build_order_str
    end

    def build_limit_str
      return "" if limit.nil?

      "LIMIT #{limit}"
    end

    def execution_successful?
      raise "execution not complete, no results to parse" unless result

      # empty select
      return true if result.empty?

      # failed upsert
      return false if (!result.rows.first["[applied]"].nil?) && (result.rows.first["[applied]"] == false)

      true
    end

    private

    def eval_if_opt?(value)
      case value
      when nil
        true # if is true by default
      when Symbol
        !!send(value)
      when String
        !!eval(value)
      else
        !!value
      end
    end

    def eval_value_opt(value)
      case value
      when Symbol
        send(value)
      when String
        eval(value)
      else
        value
      end
    end
  end
end
