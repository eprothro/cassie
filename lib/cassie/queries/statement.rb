require 'active_support/core_ext/string/filters'
require_relative 'statement/filtering'

module Cassie::Queries
  module Statement
    extend ::ActiveSupport::Concern

    included do
      include Filtering
      attr_reader :result
    end

    module ClassMethods
      def cql(statement)
        if self.const_defined?(:STATEMENT)
          raise "a cql statement has already been defined and cannot be changed"
        else
          self.const_set(:STATEMENT, statement.squish)
        end
      end

      def statement
        self.const_get(:STATEMENT)
      rescue NameError
      end
    end

    # Executes the statment, populates result
    # returns true or false indicating a successful execution or not
    def execute
      @result = session.execute(statement, arguments: bindings)
      execution_successful?
    end

    def statement
      self.class.statement
    end

    protected

    def bindings
      []
    end

    private

    def execution_successful?
      raise "execution not complete, no results to parse" unless result

      # empty select
      return true if result.empty?

      # failed upsert
      return false if (!result.rows.first["[applied]"].nil?) && (result.rows.first["[applied]"] == false)

      true
    end
  end
end
