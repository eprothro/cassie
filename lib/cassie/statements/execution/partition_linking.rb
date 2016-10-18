module Cassie::Statements::Execution
  module PartitionLinking
    require_relative 'partition_linking/simple_policy'
    require_relative 'partition_linking/cursoring_policy'

    extend ActiveSupport::Concern

    module ClassMethods
      def link_partitions(*args)
        include Peeking
        self.partition_linker_args = args
      end

      def partition_linker=(val)
        @partition_linker = val
      end

      def partition_linker
        return @partition_linker if defined?(@partition_linker)
        SimplePolicy
      end

      def partition_linker_args=(val)
        @partition_linker_args = val
      end

      def partition_linker_args
        @partition_linker_args if defined?(@partition_linker_args)
      end
    end

    def execute
      success = super
      if success && partition_linker?
        @result = build_partition_linker.link
        result.success?
      else
        success
      end
    end

    def build_partition_linker
      self.class.partition_linker.new(self, *self.class.partition_linker_args)
    end

    def partition_linker?
      !!self.class.partition_linker_args
    end
  end
end