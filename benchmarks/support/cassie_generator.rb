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
    query.simulate_execution_start
  end
end

class BenchmarkQuery < Cassie::Query

  select :friendships_by_owner

  where :owner_id, :eq
  where :friend_id, :eq

  self.prepare = false

  def initialize(object_a, object_b)
    owner_id = object_a.id
    friend_id = object_b.id
  end

  def simulate_execution_start
    # build Cassandra::Statement
    # this is passed to session.execute
    statement
  end
end