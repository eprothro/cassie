require_relative 'assignments'
require_relative 'conditions'

module Cassie::Statements::Statement
  module Updating
    extend ::ActiveSupport::Concern

    included do
      include Relations
      include Assignments
      include Conditions

      @result_class = Cassie::Statements::Results::ModificationResult
    end

    module ClassMethods
      def update(table)
        self.table = table
        self.type = :update

        yield(self) if block_given?
      end
    end

    protected

    def build_update_cql_and_params
      assignment_str, update_params = build_update_and_params
      where_str, where_params = build_where_and_params
      condition_str, condition_params = build_condition_and_params

      @cql = %(
        UPDATE #{table}
        SET #{assignment_str}
        #{where_str}
        #{condition_str}
      ).squish + ";"

      @params = update_params + where_params + condition_params
    end
  end
end