require_relative 'pagination/cursors'
require_relative 'pagination/page_size'

module Cassie::Queries::Statement
  module Pagination
    extend ActiveSupport::Concern

    included do
      include Cursors
    end

    module ClassMethods
      def inherited(subclass)
        subclass.page_size = page_size
        super
      end

      def page_size
        return @page_size if defined?(@page_size)
        PageSize.default
      end

      def page_size=(val)
        @page_size = val
      end
    end

    def page_size
      return @page_size if defined?(@page_size)
      self.class.page_size
    end

    def page_size=(val)
      @page_size = val
    end
  end
end