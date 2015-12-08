require 'active_support/core_ext/string/filters'

module Cassie::Queries
  module Statement
    extend ::ActiveSupport::Concern

    included do
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
      end

      def prepared_statement
        # use class instance variable to esnure only 1
        # statement is prepared per process
        # no mutex required in MRI because of GIL
        #
        # note: cassandra-driver handles the case
        #       of executing a prepared statement
        #       on a host where it has not been prepared
        #       yet, by re-preparing.
        @prepared_statement ||= begin
          session.prepare(statement)
        end
      end
    end

    def execute
      @result = session.execute(prepared_statement, arguments: bindings)

      execution_successful?
    end

    def statement
      self.class.statement
    end

    def prepared_statement
      self.class.prepared_statement
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
