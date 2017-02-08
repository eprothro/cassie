module Cassie
  # A concrete implementation of a functional base class used to
  # make CQL +SELECT+ queries. Inherit from this class to create application query classes.
  #
  # * The Cassandra connection is provided and managed by {Cassie::Connection}
  # * Generic statement functionality is provided by {Statements::Core}
  # * +SELECT+ specific statement DSL and functionality is provided by {Statements::Query}
  #
  # See the {file:lib/cassie/statements/README.md} for information on usage and examples.
  #
  # @example Selecting a record from a Table
  #   class UsersByUsernameQuery < Cassie::Query
  #
  #     select_from :users_by_username
  #
  #     where :username, :eq
  #
  #     def build_result(row)
  #       User.new(row)
  #     end
  #   end
  #
  #   user = UsersByUsernameQuery.new(username: 'eprothro').fetch_first
  #   #=> #<User:0x007fedec219cd8 @id=123, @username="eprothro">
  #
  class Query
    require_relative 'statements'

    include Cassie::Connection
    include Statements::Core
    include Statements::Query

  end
end
