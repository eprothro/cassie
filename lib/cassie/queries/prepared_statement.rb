module Cassie::Queries
  module PreparedStatement
    extend ::ActiveSupport::Concern

    included do
      class << self
        attr_accessor :prepare
      end
      self.prepare = true
    end

    module ClassMethods
      def inherited(subclass)
        subclass.prepare = prepare
      end

      def prepare?
        !!prepare
      end

      def prepared_statement
        # use class instance variable to esnure only 1
        # statement is prepared per process
        # no mutex required in MRI because of GIL
        #
        # note: cassandra-driver handles the case
        #       of executing a prepared statement
        #       on a host where it has not been prepared
        #       yet, by re-preparing.
        @prepared_statement ||= begin
          session.prepare(statement)
        end
      end
    end

    def statement
      self.class.prepare? ? self.class.prepared_statement : super
    end
  end
end
