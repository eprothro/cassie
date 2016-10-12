require_relative 'simple_policy'

module Cassie::Statements::Execution::PartitionLinking
  class CursoringPolicy < SimplePolicy

    def prepare_execution
      super
      # We are changing to the next partition
      # so, reset the max cursor to start at the top
      # execution.max_cursor = nil
    end
  end
end