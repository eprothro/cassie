module Cassie
  # Include Cassie::Connection to add #session and #keyspace
  # convenience methods that conform with object cacheing and reuse
  # behavior in line with Cassandra best practices
  module Connection

    extend ActiveSupport::Concern

    included do
      attr_writer :keyspace
    end

    module ClassMethods
      def keyspace(val=NilClass)
        # support DSL style
        # class Foo
        #   include Cassie::Connection
        #   keyspace :foo
        # end
        if val == NilClass
          # regular getter behavior
          return @keyspace if defined?(@keyspace)
          # fall back to global default when not
          # defined for class
          Cassie.keyspace
        else
          # DSL style set
          self.keyspace = val
        end
      end

      def keyspace=(val)
        #support Class.keyspace = :foo
        @keyspace = val
      end
    end

    def keyspace
      return @keyspace if defined?(@keyspace)
      self.class.keyspace
    end

    def session
      Cassie.session(keyspace)
    end
  end
end
