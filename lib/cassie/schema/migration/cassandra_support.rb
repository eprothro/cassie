module Cassie::Schema
  class Migration
    require_relative 'dsl'

    module CassandraSupport
      extend ActiveSupport::Concern

      included do
        include Cassie::Connection
        include DSL
      end

      def execute(*params)
        session.execute(*params)
      end

      # compatibility with casandra_migrations
      # until import handles this
      def using_keyspace(val)
        raise ArgumentError, "block required for using temporary keyspace" unless block_given?
        orignal = @keyspace if defined?(@keyspace)
        @keyspace = val

        yield

        if defined?(orignal)
          @keyspace = original
        else
          remove_instance_variable(:@keyspace)
        end
      end
    end
  end
end
