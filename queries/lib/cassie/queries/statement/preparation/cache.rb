module Cassie::Queries::Statement
  module Preparation
    class Cache
      attr_reader :data

      def initialize
        clear
        @monitor = Monitor.new
      end

      def write(key, value)
        synchronize do
          @data[key] = value
        end
      end
      def read(key)
        synchronize do
          data[key]
        end
      end
      def fetch(key)
        return read(key) if data.has_key?(key)
        write(key, yield) if block_given?
      end
      def clear
        @data = {}
      end
      def close
        clear
      end

      private

      def synchronize(&block)
        @monitor.synchronize(&block)
      end
    end

    def self.cache
      @cache ||= init_cache
    end

    def self.init_cache
      previous_cache = defined?(@cache) ? @cache : nil

      #TODO: research why memory story is blowing up when
      #     serializing the Cassandra prepared statement result
      # @cache = ActiveSupport::Cache::MemoryStore.new
      @cache = Cache.new

      previous_cache.close if previous_cache
      @cache
    end
  end
end