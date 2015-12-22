require_relative 'assignments'

module Cassie::Queries::Statement
  module Inserting
    extend ::ActiveSupport::Concern

    module ClassMethods
      def insert(table)
        include Assignments

        self.table = table
        self.identifier = :insert
        yield(self) if block_given?
      end
    end

    def insert(resource, opts={})
      execute
      execution_successful?
    end

    protected

    def build_insert_cql_and_bindings
      identifiers_str, terms_str, bindings = build_insert_and_bindings

      cql = %(
        INSERT INTO #{table}
        (#{identifiers_str})
        VALUES (#{terms_str})
      ).squish + ";"

      [cql, bindings]
    end
  end
end