module Cassie::Statements::Execution
  module Peeking
    extend ActiveSupport::Concern

    included do
      @result_class = Cassie::Statements::Results::PeekingResult
    end

    def execute
      assert_limit
      with_limit(limit + 1) { super }
    end

    protected

    def result_opts
      super.merge(limit: limit - 1)
    end

    private

    def assert_limit
      if limit.nil?
        raise ArgumentError, "Cassie Peeking is enabled, but the statement limit is `nil`. A limit is required to peek at the next result. Did you accidentally set `Cassie::Statements.limit = nil` instead of disabling the limit for only a specific query?"
      end
    end
  end
end