require_relative 'relations'
require_relative 'conditions'
require_relative 'mapping'

module Cassie::Statements::Statement
  module Deleting
    extend ::ActiveSupport::Concern

    included do
      include Relations
      include Conditions
      include Mapping

      @result_class = Cassie::Statements::Results::ModificationResult
    end

    module ClassMethods
      #TODO: accept block to add specific selectors and aliases
      #      select_from :table do |t|
      #        t.id
      #        t.name as: :username
      #      end
      def delete_from(table)
        self.table = table
        self.type = :delete

        yield(self) if block_given?
      end

      def delete(table)
        Cassie.logger.warn "[DEPRECATION] `Cassie::Modification#delete` has been replaced by `delete_from` and will be removed."
        delete_from(table)
      end


      def column(identifier, opts={})
        columns << identifier.to_s
      end

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
      str = if columns.empty?
        ''
      else
        columns.join(', ')
      end
    end
  end
end