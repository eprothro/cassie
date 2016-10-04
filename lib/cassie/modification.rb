module Cassie
  class Modification
    require_relative 'statements'

    include Cassie::Connection
    include Statements::Core
    include Statements::Modification
  end
end
