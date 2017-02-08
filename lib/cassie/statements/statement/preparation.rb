require_relative 'preparation/cache'

module Cassie::Statements::Statement
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

      def prepare
        @prepare
      end

      def prepare=(val)
        @prepare = val
      end

      # @return [Boolean] indicating whether the statement will be prepared when executed
      def prepare?
        !!prepare
      end
    end

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
