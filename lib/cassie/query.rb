module Cassie
  class Query
    require_relative 'queries/session'
    require_relative 'queries/statement'
    require_relative 'queries/instrumentation'
    require_relative 'queries/logging'

    include Queries::Session
    include Queries::Statement
    include Queries::Instrumentation
    include Queries::Logging

    def initialize(params={})
      params.each do |attr, value|
        self.public_send("#{attr}=", value)
      end

      super()
    end
  end
end
