module Cassie
  class Query
    require_relative 'statements'

    include Cassie::Connection
    include Statements::Core
    include Statements::Query

  end
end
