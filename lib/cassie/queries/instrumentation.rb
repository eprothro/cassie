require_relative 'instrumentation/execution'
require_relative 'instrumentation/loading'

module Cassie::Queries
  module Instrumentation
    extend ::ActiveSupport::Concern

    included do
      include Execution
    end

    protected

    def instrumenter
      ActiveSupport::Notifications
    end
  end
end
