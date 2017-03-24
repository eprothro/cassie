module Cassie::Schema
  class DropKeyspaceQuery < Cassie::Definition
    self.prepare = false
    consistency :all

    attr_accessor :keyspace

    def statement
      cql = %(
        DROP KEYSPACE IF EXISTS #{keyspace};
       )
    end

    def execute(opts={})
      opts[:timeout] ||= 10
      super(opts)
    end
  end
end
