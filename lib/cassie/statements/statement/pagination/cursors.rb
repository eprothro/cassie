require_relative '../relations'
require_relative '../../execution/peeking'

module Cassie::Statements::Statement::Pagination
  module Cursors
    extend ActiveSupport::Concern

    included do
      include Cassie::Statements::Statement::Relations
    end

    module ClassMethods
      def max_cursor(key)
        include Cassie::Statements::Execution::Peeking
        self.partition_linker = Cassie::Statements::Execution::PartitionLinking::CursoringPolicy

        @max_cursor_key = key

        where(key,:lteq,
              value: :"max_#{key}",
              if: :max_cursor_enabled?)

        define_max_accessors(key)
      end

      def since_cursor(key)
        include Cassie::Statements::Execution::Peeking

        @max_cursor_key = key

        where(key, :gt,
              value: :"since_#{key}",
              if: :since_cursor_enabled?)

        define_since_accessors(key)
      end

      def cursor_by(key)
        max_cursor key
        since_cursor key
      end

      def max_cursor_key
        @max_cursor_key.to_s
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
    end

    def result_class
      if cursored?
        Cassie::Statements::Results::CursoredResult
      else
        super
      end
    end

    def result_opts
      if cursored?
        super.merge({max_cursor_key: self.class.max_cursor_key})
      else
        super
      end
    end

    protected

    def cursored?
      respond_to?(:max_cursor)
    end
  end
end