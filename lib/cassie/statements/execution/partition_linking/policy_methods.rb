# Note: currently supports only natural linking
# that is in the same direction as the clustering order
module Cassie::Statements::Execution::PartitionLinking
  module PolicyMethods
    extend ActiveSupport::Concern

    included do
      attr_reader :identifier, :direction, :range, :peeking_execution, :execution
    end

    def initialize(executed, identifier, direction, range)
      @peeking_execution = executed
      @identifier = identifier
      @direction = direction
      @range = range
    end
    
    # returns linked result
    def link
      if seek_partition? && partition_available?
        prepare_execution
        execution.execute
        combine_results
      else
        peeking_execution.result
      end
    end

    def prepare_execution
      @execution = peeking_execution.clone
      change_partition
      adjust_limit
      execution
    end
    
    def seek_partition?
      end_of_partition?
    end

    def end_of_partition?
      !peeking_execution.result.peeked_row
    rescue NoMethodError => ex
      message = "Results aren't available for linking. Did you forget to call `execute`?" if peeking_execution.result.nil?
      message ||= "Peeking not enabled. To link partitions, peeking must be included in the execution. Did you forget to call `link_partitions`?"
      raise ArgumentError, message
    end

    def partition_available?
      key = ascending? ? next_key(current_key) : previous_key(current_key)
      key >= first_key && key <= last_key
    end

    protected

    def first_key
      eval_opt(range.first, peeking_execution)
    end

    def last_key
      eval_opt(range.last, peeking_execution)
    end

    def change_partition
      key = if ascending?
        # explicitly pass key to keep policy subclass
        # interface clear and consistent
        next_key(current_key)
      else
        # explicitly pass key to keep policy subclass
        # interface clear and consistent
        previous_key(current_key)
      end
      if key < first_key || key > last_key
        logger.warn("warning: linking to partition that is outside of ranges defined. #{key} outside of (#{first_key}..#{last_key}). This could result in unexpected records being returned.")
      end

      # define object singleton method to
      # override getter for partition key
      # returning the partion that needs to be linked
      execution.define_singleton_method(identifier) do
        key
      end
    end

    def adjust_limit
      execution.limit = execution.limit - peeked_rows.count
    end

    def current_key
      peeking_execution.send(identifier)
    end

    def combine_results
      rows = combine_rows(peeked_rows.to_a , execution_rows.to_a)
      execution.result.define_singleton_method(:rows) do
        rows
      end
      execution.result
    end

    def ascending?
      [:ascending, :asc, :ASC].include? direction
    end

    def peeked_rows
      peeking_execution.result.rows
    end

    def execution_rows
      execution.result.rows
    end

    def logger
      Cassie::Statements.logger
    end

    def eval_opt(value, src=source)
      case value
      when Symbol
        src.send(value)
      else
        value
      end
    end
  end
end