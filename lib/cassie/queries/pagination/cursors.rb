module Cassie::Queries::Pagination
  module Cursors
    extend ActiveSupport::Concern

    module ClassMethods
      def max_cursor(field, opts={})
        where(field, :lteq, opts)
      end

      def since_cursor(field, opts={})
        where(field, :gt, opts)
      end
    end
  end
end