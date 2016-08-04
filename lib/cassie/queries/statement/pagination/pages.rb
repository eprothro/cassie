require_relative '../relations'
require_relative '../ordering'

module Cassie::Queries::Pagination
  module Pages
    extend ActiveSupport::Concern

    included do
      include Cassie::Queries::Statement::Relations
    end

    module ClassMethods
      def next_page(key)
        @next_page_key = key

        where(key, :gt, value: :"next_page_#{key}", if: :next_page_enabled?)
        order(key: key, direction: "ASC", if: :next_page_enabled?)

        define_next_accessors(key)
      end

      def page_by(key)
        next_page key
      end

      private

      def define_next_accessors(key)
        attr_accessor :next_page

        define_method :next_page_enabled? do
          !next_page.nil?
        end

        getter = :"next_page_#{key}"
        remove_method getter if method_defined?(getter)
        define_method getter do
          self.next_page
        end

        setter = :"next_page_#{key}="
        remove_method setter if method_defined?(setter)
        define_method setter do |val|
          self.next_page = val
        end
      end
    end
  end
end
