require_relative 'assignments'
require_relative 'conditions'

module Cassie::Queries::Statement
  module Updating
    extend ::ActiveSupport::Concern

    included do
      include Relations
      include Assignments
      include Conditions
    end

    module ClassMethods
      def update(table)
        self.table = table
        self.type = :update

        yield(self) if block_given?
      end
    end

    def update(opts={})
      execute
      execution_successful?
    end

    protected

    def build_update_cql_and_bindings
      assignment_str, update_bindings = build_update_and_bindings
      where_str, where_bindings = build_where_and_bindings
      condition_str, condition_bindings = build_condition_and_bindings

      cql = %(
        UPDATE #{table}
        SET #{assignment_str}
        #{where_str}
        #{condition_str}
      ).squish + ";"

      [cql, update_bindings + where_bindings + condition_bindings]
    end
  end
end