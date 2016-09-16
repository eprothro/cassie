require_relative '../relations'

module Cassie::Queries::Statement::Pagination
  module Cursors
    extend ActiveSupport::Concern

    included do
      include Cassie::Queries::Statement::Relations
    end

    module ClassMethods
      def max_cursor(key)
        include Peeking

        @max_cursor_key = key

        where(key,:lteq,
              value: :"max_#{key}",
              if: :max_cursor_enabled?)

        define_max_accessors(key)
        define_next_max_cursor_alias(key)
      end

      def since_cursor(key)
        include Peeking

        @max_cursor_key = key

        where(key, :gt,
              value: :"since_#{key}",
              if: :since_cursor_enabled?)

        define_since_accessors(key)
        define_next_max_cursor_alias(key)
      end

      def cursor_by(key)
        max_cursor key
        since_cursor key
      end

      private

      def define_max_accessors(key)
        attr_accessor :max_cursor

        define_method :max_cursor_enabled? do
          !max_cursor.nil?
        end

        getter = :"max_#{key}"
        remove_method getter if method_defined?(getter)
        define_method getter do
          self.max_cursor
        end

        setter = :"max_#{key}="
        remove_method setter if method_defined?(setter)
        define_method setter do |val|
          self.max_cursor = val
        end
      end

      def define_since_accessors(key)
        attr_accessor :since_cursor

        define_method :since_cursor_enabled? do
          !since_cursor.nil?
        end

        getter = :"since_#{key}"
        remove_method getter if method_defined?(getter)
        define_method getter do
          self.since_cursor
        end

        setter = :"since_#{key}="
        remove_method setter if method_defined?(setter)
        define_method setter do |val|
          self.since_cursor = val
        end
      end

      def define_next_max_cursor_alias(key)
        method = "next_max_#{key}"

        unless method_defined?(method)
          define_method method do
            next_max_cursor
          end
        end
      end
    end

    module Peeking
      extend ActiveSupport::Concern

      included do
        attr_reader :next_max_cursor
      end

      module ClassMethods
        def max_cursor_key
          @max_cursor_key.to_s
        end
      end

      def limit
        super || page_size
      end

      def execute
        # get 1 extra result to determing next page info
        # but massage results to only have what client expects

        val = peek_at_next_page do
          super
        end

        extract_next_max_cursor

        val
      end

      private

      # cache query object instance page_size
      # so we can revert _object_ back to
      # same state and preserve value
      # inheritance chain behavior
      def peek_at_next_page(&block)
        old_page_size = nil
        was_defined = false

        if defined?(@page_size)
          old_page_size = @page_size
          was_defined = true
        end

        @page_size = page_size + 1
        yield
      ensure
        if was_defined
          @page_size = old_page_size
        else
          remove_instance_variable(:@page_size)
        end
      end

      # Extracts the next_max_cursor from the query results
      # given then current max_cursor and since_cursor
      # leaving the results as cursoring client expects
      #
      # Note: We modify cassie private attribute in place
      #       otherwise we have to copy rows, make results private
      #       or have a mismatch between rows in results
      #       and resources created by query class
      def extract_next_max_cursor
        raw_rows = result.instance_variable_get(:@rows)

        @next_max_cursor = if raw_rows.count > page_size
          raw_rows.delete_at(-1)[self.class.max_cursor_key]
        end
      end
    end
  end
end