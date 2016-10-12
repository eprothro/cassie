require_relative 'policy_methods'

module Cassie::Statements::Execution::PartitionLinking
  class SimplePolicy
    include PolicyMethods

    def combine_rows(rows_a, rows_b)
      rows_a + rows_b
    end

    def next_key(current_key)
      current_key + 1
    end

    def previous_key(current_key)
      current_key - 1
    end
  end
end