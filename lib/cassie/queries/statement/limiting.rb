module Cassie::Queries::Statement
  module Limiting
    extend ActiveSupport::Concern

    included do
      attr_writer :limit
    end

    module ClassMethods
      def limit=(val)
        @limit = val
      end

      def limit(val=:get)
        if val == :get
          @limit if defined?(@limit)
        else
          self.limit = val
        end
      end
    end

    def limit
      return @limit if defined?(@limit)
      self.class.limit
    end

    protected

    def build_limit_str
      return "" if limit.nil?

      "LIMIT #{limit}"
    end
  end
end