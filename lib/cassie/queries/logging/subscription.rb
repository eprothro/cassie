require_relative 'cql_execution_event'
require_relative 'building_resources_event'

module Cassie::Queries::Logging
  module Subscription
    extend ::ActiveSupport::Concern

    included do
      ActiveSupport::Notifications.subscribe('cassie.cql.execution') do |*args|
        # don't log if instrumentation failed
        unless args.last[:exception]
          logger.debug(CqlExecutionEvent.new(*args).message)
        end
      end

      ActiveSupport::Notifications.subscribe('cassie.building_resources') do |*args|
        # don't log if instrumentation failed
        unless args.last[:exception]
          logger.debug(BuildingResourcesEvent.new(*args).message)
        end
      end
    end
  end
end
