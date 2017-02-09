module Cassie::Schema
  class CreateKeyspaceQuery < Cassie::Definition
    self.prepare = false
    self.keyspace = nil

    attr_accessor :name,
                  :replication_class,
                  :replication_factor,
                  :durable_writes

    def initialize(*args)
      super(*args)
      @replication_class ||= 'SimpleStrategy'
      @replication_factor ||= 1
      @durable_writes = true unless defined?(@durable_writes)
    end

    def statement
      cql = %(
        CREATE KEYSPACE IF NOT EXISTS #{name}
        WITH replication = {'class': '#{replication_class}', 'replication_factor': '#{replication_factor}'}
        AND durable_writes = #{!!durable_writes};
       )
    end
  end
end
