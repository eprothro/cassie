module Cassie::Statements
  module Statement::TypeHinting
    extend ActiveSupport::Concern

    included do
      attr_writer :type_hints
    end

    module ClassMethods
      # @!visibility private
      def inherited(subclass)
        subclass.type_hints = type_hints if defined?(@type_hints)
        super
      end

      def type_hints=(val)
        @type_hints = val
      end

      # DSL to set the type hints execution option
      # Defaults to +nil+ if none are set
      # @param [Array, Hash] hints Hints to use for value serialization. Array for positional arguments, Hash for named arguments.
      # @return [Array, Hash] hints to use for value serialization. Array for positional arguments, Hash for named arguments.
      def type_hints(hints=:get)
        if hints == :get
          return @type_hints if defined?(@type_hints)
          nil
        else
          self.type_hints = hints
        end
      end
    end

    # The type hints for this object's statement
    # Defaults to {.type_hints} if none are set on the object
    # @return [Array, Hash] hints to use for value serialization. Array for positional arguments, Hash for named arguments.
    def type_hints
      return @type_hints if defined?(@type_hints)
      self.class.type_hints
    end
  end
end