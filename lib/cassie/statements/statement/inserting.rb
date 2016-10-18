require_relative 'assignments'
require_relative 'conditions'

module Cassie::Statements::Statement
  module Inserting
    extend ::ActiveSupport::Concern

    included do
      include Assignments
      include Conditions

      @result_class = Cassie::Statements::Results::ModificationResult
    end

    module ClassMethods
      def insert_into(table)
        self.table = table
        self.type = :insert

        yield(self) if block_given?
      end
      def insert(table)
        Cassie.logger.warn "[DEPRECATION] `Cassie::Modification#insert` has been replaced by `insert_into` and will be removed."
        insert_into(table)
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