module Cassie::Queries::Statement
  module Limiting
    extend ActiveSupport::Concern

    included do
      attr_accessor :limit

      class << self
        attr_accessor :limit
      end
    end

    def limit
      @limit || self.class.limit
    end

    protected

    def build_limit_str
      return "" if limit.nil?

      "LIMIT #{limit}"
    end
  end
end