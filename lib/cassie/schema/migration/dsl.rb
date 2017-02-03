module Cassie::Schema
  class Migration
    module DSL
      require_relative 'dsl/table_operations'
      require_relative 'dsl/column_operations'
      require_relative 'dsl/announcing'

      extend ActiveSupport::Concern

      included do
        include ColumnOperations
        include TableOperations
        include Announcing
      end
    end
  end
end
