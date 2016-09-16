module Cassie::Statements::Results
  module Core

    def success?
      # TODO: remove - don't think we need this exception
      # raise "execution not complete, no results to parse" unless result

      true
    end
  end
end