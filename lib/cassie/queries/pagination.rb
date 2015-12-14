require_relative 'pagination/cursors'
require_relative 'pagination/page_size'

module Cassie::Queries
  module Pagination
    extend ActiveSupport::Concern

    included do
      include Cursors
    end

    module ClassMethods
      def inherited(subclass)
        subclass.page_size = page_size
      end

      def page_size
        @page_size || Cassie::Queries::Pagination::PageSize.default
      end

      def page_size=(val)
        @page_size = val
      end
    end

    def page_size
      @page_size || self.class.page_size
    end

    def page_size=(val)
      @page_size = val
    end
  end
end