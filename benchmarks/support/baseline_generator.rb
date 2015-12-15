require_relative 'resource'

# We're evaluating the time it takes to go from a
# caller wanting a query executed to that query
# making being executed on the Cassandra::Session
class BaselineGenerator

  def initialize
    @query = %(
      SELECT * FROM friendships_by_owner
      WHERE owner_id = ? AND friend_id = ?;
    )
    @o1 = Resource.new
    @o2 = Resource.new
  end

  # Presumably a minimal implementation is
  # taking an object, extracting properties
  # for bindings, and passing those and a cql
  # statement string to execute
  def generate
    execution_params = [
      @query,
      [@o1.id, @o2.id]
    ]
  end
end