require 'delegate'

module Cassie::Statements
  module Results
    require_relative 'results/result'
    require_relative 'results/modification_result'
    require_relative 'results/query_result'
    require_relative 'results/peeking_result'

  end
end