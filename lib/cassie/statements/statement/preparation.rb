require_relative 'preparation/cache'

module Cassie::Statements::Statement
  module Preparation
    extend ::ActiveSupport::Concern

    included do
      class << self
        attr_accessor :prepare
      end
      self.prepare = true
    end

    module ClassMethods
      def inherited(subclass)
        subclass.prepare = prepare
        super
      end

      def prepare?
        !!prepare
      end
    end

    def statement
      statement = super

      if self.class.prepare?
        key = statement.respond_to?(:cql) ? statement.cql : statement.to_s

        unbound = statement_cache.fetch(key) do
          session.prepare(statement)
        end
        unbound.bind(statement.params)
      else
        statement
      end
    end

    private

    def statement_cache
      Cassie::Statements::Statement::Preparation.cache
    end
  end
end
