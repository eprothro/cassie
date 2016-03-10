require_relative 'logging/subscription'

module Cassie::Queries
  module Logging
    extend ::ActiveSupport::Concern

    included do
      include Subscription
    end

    module ClassMethods
      def logger
        Cassie.logger
      end
    end

    def logger
      self.class.logger
    end
  end
end
