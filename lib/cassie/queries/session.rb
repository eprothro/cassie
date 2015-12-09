module Cassie::Queries
  module Session
    extend ::ActiveSupport::Concern

    module ClassMethods
      def session
        # until cassie-configuration exists,
        # we're relying on the client to
        # supply the session
        if defined?(super)
          super
        else
          raise "Oops! Cassie::Queries doesn't manage a Cassandra session for you, yet. You must provide a .session class method that returns a valid session."
        end
      end
    end

    def session
      self.class.session
    end
  end
end
