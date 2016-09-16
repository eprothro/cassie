module Cassie::Statements::Results
  require_relative 'modification'

  class ModificationResult < Result
    include  Modification

  end
end
