# Revert patch made in break_cassandra_connection.rb
# to allow connetions to Cassandra for
# this spec run
module Cassandra
  def self.allow_connection?
    true
  end
end