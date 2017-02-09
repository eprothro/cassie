require_relative 'assignments'
require_relative 'conditions'

module Cassie::Statements::Statement
  module Inserting

    # @!visibility private
    # @!parse include Assignments
    # @!parse extend Assignments::ClassMethods
    # @!parse include Conditions
    # @!parse extend Conditions::ClassMethods
    def self.included(base)
      base.instance_eval do
        include Assignments
        include Conditions

        @result_class = Cassie::Statements::Results::ModificationResult
      end
      base.extend ClassMethods
    end

    # @!parse extend ClassMethods
    module ClassMethods
      # DSL to set the statement type and table for insertion
      # @param [String, Symbol] table The table to taret for the insert statement
      # @return [void]
      def insert_into(table)
        self.table = table
        self.type = :insert

        yield(self) if block_given?
      end
    end

    protected

    def build_insert_cql_and_params
      identifiers_str, terms_str, value_params = build_insert_and_params
      condition_str, condition_params = build_condition_and_params

      @cql = %(
        INSERT INTO #{table}
        (#{identifiers_str})
        VALUES (#{terms_str})
        #{condition_str}
      ).squish + ";"

      @params = value_params + condition_params
    end
  end
end