module Cassie::Statements::Results
  module Core

    def success?
      # @todo remove - don't think we need this exception
      # raise "execution not complete, no results to parse" unless result

      true
    end
  end
end