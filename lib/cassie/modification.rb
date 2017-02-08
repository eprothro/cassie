module Cassie
  # A concrete implementation of a functional base class used to
  # make CQL +INSERT+, +UPDATE+, and +DELETE+ queries.
  # Inherit from this class to create application query classes.
  #
  # * The Cassandra connection is provided and managed by {Cassie::Connection}
  # * Generic statement functionality is provided by {Statements::Core}
  # * +INSERT|UPDATE|DELETE+ specific statement DSL and functionality is provided by {Statements::Modification}
  #
  # See the {file:lib/cassie/statements/README.md} for information on usage and examples.
  #
  # @example Inserting a record into a Table
  #   class InsertUserQuery < Cassie::Modification
  #
  #     insert_into :users_by_username
  #     consistency :all
  #
  #     set :id
  #     set :username
  #
  #     map_from :user
  #
  #     def id
  #       Cassandra::TimeUuid::Generator.new.now
  #     end
  #   end
  #
  #   InsertUserQuery.new(user: user).excecute
  #   #=> true
  #
  class Modification
    require_relative 'statements'

    include Cassie::Connection
    include Statements::Core
    include Statements::Modification
  end
end
