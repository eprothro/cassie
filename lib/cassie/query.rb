module Cassie
  # think about ActiveSupport autoloading
  require_relative 'queries/statement'
  require_relative 'queries/instrumentation'
  require_relative 'queries/log_subscription'

  class Query
    include Queries::Statement
    include Queries::Instrumentation
    include Queries::LogSubscription
  end
end