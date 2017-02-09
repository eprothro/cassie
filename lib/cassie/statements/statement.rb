require 'active_support/core_ext/string/filters'
require 'active_support/hash_with_indifferent_access'

module Cassie::Statements
  # Include Statement to provide support for a
  # `statement` method returning a `Cassandra::Statements::Simple`
  # statement with positional arguments.
  #
  # `type` and `table` attributes are also added,
  # providing an extension interface for building
  # cql and bindings for different statement types.
  module Statement
    require_relative 'statement/preparation'
    require_relative 'statement/type_hinting'
    require_relative 'statement/idempotency'

    class Invalid < StandardError; end

    # @!visibility private
    # @!parse include Preparation
    # @!parse extend Preparation::ClassMethods
    # @!parse include TypeHinting
    # @!parse include TypeHinting::ClassMethods
    # @!parse include Idempotency
    # @!parse include Idempotency::ClassMethods
    def self.included(base)
      base.instance_eval do
        include Preparation
        include TypeHinting
        include Idempotency

        class << self
          attr_accessor :table
          attr_accessor :type
        end
      end
    end

    def table
      self.class.table
    end

    # A bound statment with type hint and idempotent options, ready for execution ready for execution with a [Cassandra::Session]
    # @return [Cassandra::Statement]
    def statement
      Cassandra::Statements::Simple.new(*build_cql_and_params, type_hints, idempotent?)
    end

    # A CQL string with inline parameters, representing the current statement
    # as it would be executed in a CQL shell
    #
    # @note This CQL string does not include execution options like type hinting,
    #  idempotency, consistency level, etc -- just the raw CQL instruction and values.
    # @return [String]
    #
    # @example
    #   statement.to_cql
    #   #=> "SELECT * FROM table WHERE first='evan' AND middle='thomas' and last='prothro"
    def to_cql
      if statement.respond_to?(:cql) && statement.respond_to?(:params)
        Cassie::Support::StatementParser.new(statement).to_cql
      else
        statement.to_s
      end
    end

    def logger
      Cassie::Statements.logger
    end

    # The CQL string portion for the statment
    # @!parse attr_reader :cql
    # @example
    #   statement.cql
    #   #=> "SELECT * FROM table WHERE first=? AND middle=? and last=?"
    def cql
      return @cql if defined?(@cql)
      ""
    end

    # The positional values portion for the statment
    # @example
    #   statement.params
    #   #=> ['evan', 'thomas', 'prothro']
    # @!parse attr_reader :params
    def params
      return @params if defined?(@params)
      nil
    end

    protected

    def build_cql_and_params
      if self.class.type
        send "build_#{self.class.type}_cql_and_params"
      end

      [cql, params]
    end

    private

    def source_eval(value, src=self)
      case value
      when Symbol
        src.send(value)
      else
        value
      end
    end
  end
end
