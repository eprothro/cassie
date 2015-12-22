require_relative 'assignments'

module Cassie::Queries::Statement
  module Updating
    extend ::ActiveSupport::Concern

    module ClassMethods
      def update(table)
        include Relations
        include Assignments

        self.table = table
        self.identifier = :update
      end
    end

    def update(resource, opts={})
      execute
      execution_successful?
    end

    protected

    def build_update_cql_and_bindings
      assignment_str, update_bindings = build_update_and_bindings
      where_str, where_bindings = build_where_and_bindings

      cql = %(
        UPDATE #{table}
        SET #{assignment_str}
        #{where_str}
      ).squish + ";"

      [cql, update_bindings + where_bindings]
    end
  end
end