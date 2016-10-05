module Cassie::Statements::Results
  require_relative 'core'

  class Result < SimpleDelegator
    # __obj__ is Cassandra::Result, which is enumerable
    include Core

    def initialize(obj, opts={})
      super(obj)
      after_initialize(opts)
    end

    protected

    # Result will be the superclass
    # of concrete result classes
    # so any overrides defined in subclasses
    # or modules included in subclasses
    # will get called first
    def after_initialize(opts)
    end
  end
end