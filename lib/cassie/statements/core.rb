require_relative 'statement'
require_relative 'execution'
require_relative 'logging'

module Cassie::Statements
  module Core

    # @!visibility private
    # @!parse include Statement
    # @!parse include Statement::ClassMethods
    # @!parse include Execution
    # @!parse include Execution::ClassMethods
    # @!parse include Logging
    # @!parse include Logging::ClassMethods
    def self.included(base)
      base.instance_eval do
        include Statement
        include Execution
        include Logging
      end
    end

    def initialize(params={})
      params.each do |attr, value|
        self.public_send("#{attr}=", value)
      end

      super()
    end
  end
end