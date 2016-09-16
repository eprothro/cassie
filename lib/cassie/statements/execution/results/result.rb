module Cassie::Statements::Results
  require_relative 'core'

  class Result < SimpleDelegator
    # __obj__ is Cassandra::Result, which is enumerable
    include Core

    def initialize(obj, opts={})
      super(obj)
    end

  end
end