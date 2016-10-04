module Cassie::Statements::Results
  require_relative 'querying'

  class QueryResult < Result
    include  Querying

  end
end

