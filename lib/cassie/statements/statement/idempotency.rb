module Cassie::Statements
  def self.default_idempotency
    return @default_idempotency if defined?(@default_idempotency)
    true
  end

  def self.default_idempotency=(val)
    @default_idempotency = val
  end


  module Statement::Idempotency
    def self.included(base)
      base.instance_eval do
        attr_writer :idempotent
        extend ClassMethods
      end
    end

    module ClassMethods
      def inherited(subclass)
        subclass.idempotent = idempotent if defined?(@idempotent)
        super
      end

      def idempotent=(val)
        @idempotent = val
      end

      def idempotent(val=:get)
        if val == :get
          return @idempotent if defined?(@idempotent)
          Cassie::Statements.default_idempotency
        else
          self.idempotent = val
        end
      end

      def non_idempotent
        self.idempotent = false
      end

      def idempotent?
        !!idempotent
      end
    end

    def idempotent
      return @idempotent if defined?(@idempotent)
      self.class.idempotent
    end

    def idempotent?
      !!idempotent
    end
  end
end