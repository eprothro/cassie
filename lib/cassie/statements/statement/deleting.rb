require_relative 'relations'
require_relative 'conditions'
require_relative 'mapping'

module Cassie::Statements::Statement
  module Deleting

    # @!visibility private
    # @!parse include Relations
    # @!parse extend Relations::ClassMethods
    # @!parse include Conditions
    # @!parse extend Conditions::ClassMethods
    # @!parse include Mapping
    # @!parse extend Mapping::ClassMethods
    def self.included(base)
      base.instance_eval do
        include Relations
        include Conditions
        include Mapping

        @result_class = Cassie::Statements::Results::ModificationResult
      end
      base.extend ClassMethods
    end

    # @!parse extend ClassMethods
    module ClassMethods
      # DSL to set the statement type and table for deleting
      # @param [String, Symbol] table The table to taret for the delete statement
      # @return [void]
      def delete_from(table)
        self.table = table
        self.type = :delete

        yield(self) if block_given?
      end

      # Add a specific column to tombstone by this statement
      # @param [String, Symbol] identifier the column to tombstone
      def column(identifier)
        # @todo replace with Selection
        # Module and aliases?
        columns << identifier.to_s
      end

      # The columns to be tombstoned from this statement
      # @return [Array<String>] column names
      def columns
        @columns ||= []
      end
    end

    protected

    def build_delete_cql_and_params
      where_str, where_params = build_where_and_params
      condition_str, condition_params = build_condition_and_params

      @cql = %(
        DELETE #{build_delete_clause}
          FROM #{table}
          #{where_str}
          #{condition_str}
      ).squish + ";"

      @params = where_params + condition_params
    end

    # a delete clause is built up of zero or more columns
    def columns
      self.class.columns
    end

    def build_delete_clause
      if columns.empty?
        ''
      else
        columns.join(', ')
      end
    end
  end
end