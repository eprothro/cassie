module Cassie::Statements
  def self.default_consistency
    return @default_consistency if defined?(@default_consistency)
    nil
  end

  def self.default_consistency=(val)
    @default_consistency = val
  end

  module Execution::Consistency
    extend ActiveSupport::Concern

    included do
      attr_writer :consistency
    end

    module ClassMethods
      def inherited(subclass)
        subclass.consistency = consistency if defined?(@consistency)
        super
      end

      def consistency=(val)
        @consistency = val
      end

      def consistency(val=:get)
        if val == :get
          return @consistency if defined?(@consistency)
          Cassie::Statements.default_consistency
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