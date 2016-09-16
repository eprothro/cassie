require_relative 'limiting'
require_relative 'pagination'
require_relative 'relations'
require_relative 'ordering'
require_relative 'fetching'

module Cassie::Queries::Statement
  module Selection
    extend ::ActiveSupport::Concern

    included do
      include Limiting
      include Pagination
      include Relations
      include Ordering
      include Fetching
    end

    module ClassMethods
      #TODO: accept block to add specific selectors and aliases
      #      select :table do |t|
      #        t.id
      #        t.name as: :username
      #      end
      def select(table)
        self.table = table
        self.type = :select

        yield(self) if block_given?
      end

      # a select clause is built up of selectors
      def selectors
        @selectors ||= []
      end
    end

    protected

    def build_select_cql_and_bindings
      where_str, bindings = build_where_and_bindings

      cql = %(
        SELECT #{build_select_clause}
          FROM #{table}
          #{where_str}
          #{build_order_str}
          #{build_limit_str}
      ).squish + ";"

      [cql, bindings]
    end

    # a select clause is built up of selectors
    def selectors
      self.class.selectors
    end

    def build_select_clause
      str = if selectors.empty?
        '*'
      else
        selectors.join(', ')
      end
    end
  end
end