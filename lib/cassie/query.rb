module Cassie
  require 'cassandra'
  require_relative 'queries/session'
  require_relative 'queries/statement'
  require_relative 'queries/pagination'
  require_relative 'queries/instrumentation'
  require_relative 'queries/logging'

  class Query
    include Queries::Session
    include Queries::Statement
    include Queries::Pagination
    include Queries::Instrumentation
    include Queries::Logging

    def initialize(*args)
      value = super(*args)
      after_initialize(*args)
      value
    end

    def after_initialize(*args)
    end
  end
end