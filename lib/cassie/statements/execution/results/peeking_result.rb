module Cassie::Statements::Results
  require_relative 'querying'
  require_relative 'peeking'

  class PeekingResult < Result
    include  Querying
    include  Peeking

  end
end