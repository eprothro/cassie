module Cassie
  class Definition
    require_relative 'statements'

    include Cassie::Connection
    include Statements::Core
  end
end
