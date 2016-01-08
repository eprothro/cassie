require_relative 'assignments'
require_relative 'conditions'

module Cassie::Queries::Statement
  module Inserting
    extend ::ActiveSupport::Concern

    module ClassMethods
      def insert(table)
        include Assignments
        include Conditions

        self.table = table
        self.identifier = :insert

        yield(self) if block_given?
      end
    end

    def insert(opts={})
      execute
      execution_successful?
    end

    protected

    def build_insert_cql_and_bindings
      identifiers_str, terms_str, value_bindings = build_insert_and_bindings
      condition_str, condition_bindings = build_condition_and_bindings

      cql = %(
        INSERT INTO #{table}
        (#{identifiers_str})
        VALUES (#{terms_str})
        #{condition_str}
      ).squish + ";"

      [cql, value_bindings + condition_bindings]
    end
  end
end