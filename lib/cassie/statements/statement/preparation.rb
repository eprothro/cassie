require_relative 'preparation/cache'

module Cassie::Statements::Statement
  # Sepcific functionality and DSL for prepared statements.
  #
  # When included, a local, in-memory statement cache will be used
  # when generating the statement object if +prepared?+ is +true+.
  #
  # By default, {.prepare} defaults to +true+, since most statements should be prepared.
  #
  # The cache key is the +cql+ for the statment, or the statement itself
  # if it does not respond to +cql+. For bound statments (recommended)
  # this results in only cacheing once per unique statement type, independent
  # of the values for a particular statemtn (which are in the +params+ attribute, not the +cql+ attribute).
  #
  # The following class attributes are affected when included:
  # * Sets {.prepared} to +true+ since most statements should be prepared.
  module Preparation
    # @!visibility private
    def self.included(base)
      base.extend ClassMethods
      base.instance_eval do
        self.prepare = true
      end
    end

    # @!parse extend ClassMethods
    module ClassMethods

      #@!visibility private
      def inherited(subclass)
        subclass.prepare = prepare
        super
      end

      # @return [Boolean] whether the statement will be prepared when executed
      def prepare
        @prepare
      end

      def prepare=(val)
        @prepare = !!val
      end

      # @return [Boolean] indicating whether the statement will be prepared when executed
      def prepare?
        !!prepare
      end
    end

    # override. The statement object, fetched from perpared statements
    # cache if {#prepare?} is +true+
    # @return [Cassandra::Statements::Prepared, Object] A bound,
    # prepared statement if {#prepare?} is +true+, otherwise +super+
    def statement
      statement = super
      if self.class.prepare?
        key = statement.respond_to?(:cql) ? statement.cql : statement.to_s

        unbound = statement_cache.fetch(key) do
          statement.cql.freeze
          session.prepare(statement)
        end
        unbound.bind(statement.params)
      else
        statement
      end
    end

    protected

    def statement_cache
      Cassie::Statements::Statement::Preparation.cache
    end
  end
end
