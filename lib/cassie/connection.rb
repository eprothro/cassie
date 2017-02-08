module Cassie
  # Defines interface providing Cassandra connection management
  # including object cacheing and reuse
  # behavior in line with Cassandra best practices
  #
  # +include Cassie::Connection+ to add +keyspace+
  # and +session+ attributes to the including module.
  module Connection

    # @!visibility private
    def self.included(base)
      base.instance_eval do
        attr_writer :keyspace
      end
      base.extend ClassMethods
    end

    # @!parse extend ClassMethods
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
        #support non DSL style Class.keyspace = :foo
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
