module Cassie::Statements  
  module Statement::TypeHinting
    extend ActiveSupport::Concern

    included do
      attr_writer :type_hints
    end

    module ClassMethods
      def inherited(subclass)
        subclass.type_hints = type_hints if defined?(@type_hints)
        super
      end

      def type_hints=(val)
        @type_hints = val
      end

      def type_hints(val=:get)
        if val == :get
          return @type_hints if defined?(@type_hints)
          nil
        else
          self.type_hints = val
        end
      end
    end

    def type_hints
      return @type_hints if defined?(@type_hints)
      self.class.type_hints
    end
  end
end