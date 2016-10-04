require_relative 'statement'
require_relative 'execution'
require_relative 'logging'

module Cassie::Statements
  module Core
    extend ActiveSupport::Concern

    included do
      include Statement
      include Execution
      include Logging
    end

    def initialize(params={})
      params.each do |attr, value|
        self.public_send("#{attr}=", value)
      end

      super()
    end
  end
end