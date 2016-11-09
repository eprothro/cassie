module Cassie::Statements::Execution
  module Peeking
    extend ActiveSupport::Concern

    included do
      @result_class = Cassie::Statements::Results::PeekingResult
    end

    def execute
      assert_limit
      @unpeeked_limit = limit
      with_limit(limit + 1) do
       super
      end
    end
    
    def unpeeked_limit
      @unpeeked_limit if defined?(@unpeeked_limit)
    end

    protected

    def result_opts
      super.merge(limit: unpeeked_limit || limit)
    end

    private

    def assert_limit
      if limit.nil?
        raise ArgumentError, "Cassie Peeking is enabled, but the statement limit is `nil`. A limit is required to peek at the next result. Did you accidentally set `Cassie::Statements.limit = nil` instead of disabling the limit for only a specific query?"
      end
    end
  end
end