require_relative 'assignments'
require_relative 'conditions'

module Cassie::Statements::Statement
  module Updating

    # @!visibility private
    # @!parse include Relations
    # @!parse extend Relations::ClassMethods
    # @!parse include Assignments
    # @!parse extend Assignments::ClassMethods
    # @!parse include Conditions
    # @!parse extend Conditions::ClassMethods
    def self.included(base)
      base.instance_eval do
        include Relations
        include Assignments
        include Conditions

        @result_class = Cassie::Statements::Results::ModificationResult
      end
      base.extend ClassMethods
    end

    # @!parse extend ClassMethods
    module ClassMethods
      # DSL to set the statement type and table for updating
      # @param [String, Symbol] table The table to taret for the update statement
      # @return [void]
      def update(table)
        self.table = table
        self.type = :update

        yield(self) if block_given?
      end
    end

    protected
    # Sets the {#cql} and {#params} for a building a bound statement
    # @return [void]
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