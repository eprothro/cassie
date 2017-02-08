require 'active_support/core_ext/hash/indifferent_access'

module Cassie
  # Contains components for managing cluster configuration
  module Configuration
    require_relative 'configuration/generator'
    require_relative 'configuration/core'

  end
end
