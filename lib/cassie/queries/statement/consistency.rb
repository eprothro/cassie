module Cassie::Queries::Statement
  module Consistency
    extend ActiveSupport::Concern

    included do
      attr_writer :consistency
    end

    module ClassMethods
      def inherited(subclass)
        subclass.consistency = consistency
        super
      end

      def consistency=(val)
        @consistency = val
      end

      def consistency(val=:get)
        if val == :get
          @consistency if defined?(@consistency)
        else
          self.consistency = val
        end
      end
    end

    def consistency
      return @consistency if defined?(@consistency)
      self.class.consistency
    end
  end
end