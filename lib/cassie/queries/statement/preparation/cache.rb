module Cassie::Queries::Statement
  module Preparation
    def self.cache
      @cache ||= init_cache
    end

    def self.init_cache
      previous_cache = defined?(@cache) ? @cache : nil

      @cache = ActiveSupport::Cache::MemoryStore.new

      previous_cache.close if previous_cache
      @cache
    end
  end
end