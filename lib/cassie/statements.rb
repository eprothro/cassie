module Cassie
  # Contains components related to Cassandra statements, including
  # * building with a CQL DSL
  # * options for executing built statements
  # * executing built statements
  # * instrumenting
  # * logging (using instrumentation)
  #
  # See +Statements+ submodules for more information on the responsibilities of
  # these individual components.
  #
  # See {Cassie::Query}, {Cassie::Modification} or {Cassie::Definition}
  # to see concrete query interfaces implementeing these components.
  module Statements
    require_relative 'statements/core'
    require_relative 'statements/query'
    require_relative 'statements/modification'
    require_relative 'statements/logging'
  end
end