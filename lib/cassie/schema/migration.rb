module Cassie::Schema
  class Migration
    require_relative 'migration/cassandra_support'

    include CassandraSupport
  end
end