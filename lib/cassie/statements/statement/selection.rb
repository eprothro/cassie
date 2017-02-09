require_relative 'limiting'
require_relative 'allow_filtering'
require_relative 'pagination'
require_relative 'relations'
require_relative 'ordering'

module Cassie::Statements::Statement
  # Sepcific functionality and DSL for selection statements
  #
  # The following class attributes are affected when included:
  # * Sets {.idempotent} to +true+ since selection queries are idempotent by definition.
  # * Sets the {.result_class} to {Cassie::Statements::Results::QueryResult}
  module Selection

    # @!visibility private
    # @!parse include Relations
    # @!parse extend Relations::ClassMethods
    # @!parse include Ordering
    # @!parse extend Ordering::ClassMethods
    # @!parse include Limiting
    # @!parse extend Limiting::ClassMethods
    # @!parse include AllowFiltering
    # @!parse extend AllowFiltering::ClassMethods
    # @!parse include Pagination
    # @!parse extend Pagination::ClassMethods
    def self.included(base)
      base.instance_eval do
        include Relations
        include Ordering
        include Limiting
        include AllowFiltering
        include Pagination

        @result_class = Cassie::Statements::Results::QueryResult
        @idempotent = true
      end
      base.extend ClassMethods
    end

    module ClassMethods
      # DSL to set the statement type and table for selection
      # @param [String, Symbol] table The table to taret for the select statement
      # @return [void]
      def select_from(table)
        self.table = table
        self.type = :select

        yield(self) if block_given?
      end

      # DSL to add a column to be ruturned for each row in the query results
      # @param [String, Symbol] column The column name in the CQL schmea to return
      # @param [Hash] opts options for the selector
      # @option opts [String] :as The identifier to use for the field when returned in the result if different than the column name
      # @return [String] the current enumeration of selectors
      def select(column, opts={})
        column = column.to_s
        column += " AS #{opts[:as]}" if opts[:as]
        selectors << column
      end

      # The enumeration of selectors for use in the statement
      # @return [Array<String>]
      def selectors
        @selectors ||= []
      end

      # DSL to wrap a selector in the +WRITETIME+ CQL,
      # used to select the time the field was written
      # instead of the value itself
      def write_time(selector)
        "WRITETIME(#{selector})"
      end
      alias writetime write_time

      # DSL to wrap a selector in the +TTL+ CQL,
      # used to select the time until the field will be
      # tombstoned, instead of the value itself
      def ttl(selector)
        "TTL(#{selector})"
      end

      # DSL to wrap a selector in the +COUNT+ CQL,
      # used to select the aggregation of the number of rows
      # instead of the value in each row
      def count(selector='*')
        "COUNT(#{selector})"
      end
    end

    protected

    def result_opts
      opts = {}
      opts[:each_deserializer] = method(:build_result) if respond_to?(:build_result, true)
      opts[:deserializer] = method(:build_results) if respond_to?(:build_results, true)
      super.merge(opts)
    end

    def build_select_cql_and_params
      where_str, @params = build_where_and_params

      @cql = %(
        SELECT #{build_select_clause}
          FROM #{table}
          #{where_str}
          #{build_order_str}
          #{build_limit_str}
          #{build_allow_filtering_str}
      ).squish + ";"
    end

    # a select clause is built up of selectors
    def selectors
      self.class.selectors
    end

    def build_select_clause
      return '*' if selectors.empty?

      selectors.join(', ')
    end
  end
end