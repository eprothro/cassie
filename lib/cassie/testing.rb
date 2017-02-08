module Cassie
  # Various modules and classes for use during application
  # testing. These classes are not loaded by +require 'cassie'+.
  # Execute +require 'cassie/testing'+ during test setup to include
  # test harnessing features.
  module Testing
    require_relative 'testing/fake/definition'
    require_relative 'testing/fake/query'
    require_relative 'testing/fake/modification'

  end
end
