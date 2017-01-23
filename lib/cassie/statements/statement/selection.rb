require_relative 'limiting'
require_relative 'allow_filtering'
require_relative 'pagination'
require_relative 'relations'
require_relative 'ordering'

module Cassie::Statements::Statement
  module Selection
    extend ::ActiveSupport::Concern

    included do
      include Relations
      include Ordering
      include Limiting
      include AllowFiltering
      include Pagination

      @result_class = Cassie::Statements::Results::QueryResult
      @idempotent = true
    end

    module ClassMethods
      def select_from(table)
        self.table = table
        self.type = :select

        yield(self) if block_given?
      end

      def select(selector, opts={})
        selector = selector.to_s
        selector += " AS #{opts[:as]}" if opts[:as]
        selectors << selector
      end

      # a select clause is built up of selectors
      def selectors
        @selectors ||= []
      end

      def write_time(selector)
        "WRITETIME(#{selector})"
      end
      alias writetime write_time

      def ttl(selector)
        "TTL(#{selector})"
      end

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