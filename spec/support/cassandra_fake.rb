require 'cassie/testing/cassandra_fake'

class Cassie::Query
  def self.session
    @session ||= CassandraFake::Session.new
  end
end