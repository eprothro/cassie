require './lib/cassie-queries'
require_relative 'resource'

# We're evaluating the time it takes to go from a
# caller wanting a query executed to that query
# making being executed on the Cassandra::Session
class CassieGenerator

  def initialize
    @o1 = Resource.new
    @o2 = Resource.new
  end

  def generate
    query = BenchmarkQuery.new(@o1, @o2)
    execution_params = [query.statement, query.bindings]
  end
end

class BenchmarkQuery < Cassie::Query

  cql %(
    SELECT * FROM friendships_by_owner
    WHERE owner_id = ? AND friend_id = ?;
  )

  self.prepare = false

  attr_accessor :object_a, :object_b

  def initialize(object_a, object_b)
    @object_a  = object_a
    @object_b = object_b
  end

  def bindings
    [
      object_a.id,
      object_b.id
    ]
  end
end