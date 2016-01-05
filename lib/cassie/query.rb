module Cassie
  # Active Support used for
  #  * include convenience via ActiveSupport::Concern
  #  * string extensions
  #  * notification pub/sub
  #  * log formatting
  #
  # We require/autoload extensions only as needed,
  # this base require has almost no overhead
  #
  # http://guides.rubyonrails.org/active_support_core_extensions.html
  require 'active_support'
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

    def initialize(params={})
      params.each do |attr, value|
        self.public_send("#{attr}=", value)
      end

      super()
    end
  end
end