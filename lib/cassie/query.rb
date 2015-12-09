module Cassie
  require 'cassandra'
  require_relative 'queries/session'
  require_relative 'queries/statement'
  require_relative 'queries/prepared_statement'
  require_relative 'queries/instrumentation'
  require_relative 'queries/logging'

  class Query
    include Queries::Session
    include Queries::Statement
    include Queries::PreparedStatement
    include Queries::Instrumentation
    include Queries::Logging
  end
end