module Cassie::Statements
  def self.default_idempotency
    return @default_idempotency if defined?(@default_idempotency)
    true
  end

  def self.default_idempotency=(val)
    @default_idempotency = val
  end


  # Sepcific functionality and DSL for idempotent statements.
  module Statement::Idempotency
    # @!visibility private
    def self.included(base)
      base.instance_eval do
        attr_writer :idempotent
      end
      base.extend ClassMethods
    end

    # @!parse extend ClassMethods
    module ClassMethods
      # @!visibility private
      def inherited(subclass)
        subclass.idempotent = idempotent if defined?(@idempotent)
        super
      end

      def idempotent=(val)
        @idempotent = val
      end

      # DSL to set a statement as idempotent
      # @param [Boolean] val The value to set for idempotency. Returns the current value if no parameter is given.
      # @return [Boolean] idempotent value
      def idempotent(val=:get)
        if val == :get
          return @idempotent if defined?(@idempotent)
          Cassie::Statements.default_idempotency
        else
          self.idempotent = val
        end
      end

      # DSL to set a satement as non-idempotent
      # @return [Boolean] false
      def non_idempotent
        self.idempotent = false
      end

      # Indicates where the statement has no negative side-effect
      # if issued multiple times.
      # @return [Boolean] indicating idempotency. Defaults to {Cassie::Statements.default_idempotency} if no value has been set.
      def idempotent?
        !!idempotent
      end
    end

    # Indicates where the statement has no negative side-effect
    # if issued multiple times.
    # @return [Boolean] indicating idempotency. Defaults to {Cassie::Statements.default_idempotency} if no value has been set.
    def idempotent
      return @idempotent if defined?(@idempotent)
      self.class.idempotent
    end

    # Indicates where the statement has no negative side-effect
    # if issued multiple times.
    # @return [Boolean] indicating idempotency. Defaults to {Cassie::Statements.default_idempotency} if no value has been set.
    def idempotent?
      !!idempotent
    end
  end
end