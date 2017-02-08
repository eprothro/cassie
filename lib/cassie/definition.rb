module Cassie
  # A concrete implementation of a functional base class used to
  # make CQL DDL or generic queries without any DSL.
  # Inherit from this class to create application query classes.
  #
  # * The Cassandra connection is provided and managed by {Cassie::Connection}
  # * Generic statement functionality is provided by {Statements::Core}
  # * Defining the statement and options is up the subclass's responsibility (e.g. no DSL is provided)
  #
  # See the {file:lib/cassie/statements/README.md} for information on usage and examples.
  #
  # @example Inserting a record into a Table
  #   class CreateKeyspaceQuery < Cassie::Definition
  #     attr_accessor :keyspace
  #
  #     self.prepare = false
  #
  #     def statement
  #       cql = %(
  #         CREATE KEYSPACE #{keyspace}
  #         WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}
  #         AND durable_writes = true;
  #        )
  #     end
  #   end
  #
  #   CreateKeyspaceQuery.new(keyspace: "my keyspace").excecute
  #   #=> true
  #
  class Definition
    require_relative 'statements'

    include Cassie::Connection
    include Statements::Core
  end
end
