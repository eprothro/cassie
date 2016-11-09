require_relative 'simple_policy'

module Cassie::Statements::Execution::PartitionLinking
  class CursoringPolicy < SimplePolicy
    
    def combine_rows(rows_a, rows_b)
      return super unless peeking_execution.since_cursor
      rows_b
    end
    
    def adjust_limit
      return super unless peeking_execution.since_cursor
      # leave the limit to return all results
      # from latest partition
    end

    def seek_partition?
      return super unless peeking_execution.since_cursor
      raise "linking partitions only supported for descending orderings. Open an issue if you need this!" if ascending?
      
      # linking while cursoring with since
      # should return latest results
      current_key != last_key
    end
    
    def previous_key(current_key)
      return super unless peeking_execution.since_cursor
      
      # linking while cursoring with since
      # should return results from latest partition
      last_key 
    end
  end
end