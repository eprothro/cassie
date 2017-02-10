module Cassie::Schema
  class Migration
    require_relative 'migration/cassandra_support'

    include CassandraSupport

    def path
      method = method(:up) || method(:down)
      method.source_location.first
    end
  end
end