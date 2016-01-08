require_relative 'relations'
require_relative 'conditions'
require_relative 'mapping'

module Cassie::Queries::Statement
  module Deleting
    extend ::ActiveSupport::Concern

    module ClassMethods
      #TODO: accept block to add specific selectors and aliases
      #      select :table do |t|
      #        t.id
      #        t.name as: :username
      #      end
      def delete(table)
        include Relations
        include Conditions
        include Mapping

        self.table = table
        self.identifier = :delete

        yield(self) if block_given?
      end

      # TODO rename to identifiers and extract
      def selectors
        @selectors ||= []
      end
    end

    def delete(opts={})
      execute
      execution_successful?
    end

    protected

    def build_delete_cql_and_bindings
      where_str, where_bindings = build_where_and_bindings
      condition_str, condition_bindings = build_condition_and_bindings

      cql = %(
        DELETE #{build_delete_clause}
          FROM #{table}
          #{where_str}
          #{condition_str}
      ).squish + ";"

      [cql, where_bindings + condition_bindings]
    end

    # a select clause is built up of selectors
    def selectors
      self.class.selectors
    end

    def build_delete_clause
      str = if selectors.empty?
        ''
      else
        selectors.join(', ')
      end
    end
  end
end