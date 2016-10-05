module Cassie::Statements
  def self.default_limit
    return @default_limit if defined?(@default_limit)
    500
  end

  def self.default_limit=(val)
    @default_limit = val
  end


  module Statement::Limiting
    extend ActiveSupport::Concern

    included do
      attr_writer :limit
    end

    module ClassMethods
      def inherited(subclass)
        subclass.limit = limit if defined?(@limit)
        super
      end

      def limit=(val)
        @limit = val
      end

      def limit(val=:get)
        if val == :get
          return @limit if defined?(@limit)
          Cassie::Statements.default_limit
        else
          self.limit = val
        end
      end
    end

    def limit
      return @limit if defined?(@limit)
      self.class.limit
    end

    def with_limit(temp_limit)
      raise ArgumentError, "block required for passing temporary limit" unless block_given?
      define_limit_singleton(temp_limit)

      yield
    ensure
      remove_limit_singleton
    end

    protected

    def build_limit_str
      return "" if limit.nil?

      "LIMIT #{limit}"
    end

    private

    def initialize_copy(other)
      super
      remove_limit_singleton
    end

    def define_limit_singleton(temp_limit)
      assert_no_limit_singleton
      define_singleton_method(:limit) do
        temp_limit
      end
    end

    def remove_limit_singleton
      if singleton_methods.include?(:limit)
        class << self
          remove_method :limit
        end
      end
    end

    def assert_no_limit_singleton
      if singleton_methods.include?(:limit)
        raise NameError.new("A singleton method has already been defined for `limit`. `with_limit` can't be implemented.", :limit)
      end
    end
  end
end