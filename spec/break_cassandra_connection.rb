# Break cassandra cluster for unit specs
# which should not rely on database
# db_spec_helper undoes this patch
# for spec runs that should require db
module Cassie::Testing
  module BrokenConnection
    def self.included(includer)
      class << includer
        prepend ClassMethods
        # mix in our types extensions
        # 'below' the base class definition
        # so we _override_ the extensions instead of
        # _overwriting_ them (e.g. so we can use `super`)
        #
        # http://stackoverflow.com/questions/4470108/when-monkey-patching-a-method-can-you-call-the-overridden-method-from-the-new-i#answer-4471202
      end
    end
    module ClassMethods
      def cluster(*args)
        if respond_to?(:allow_connection?) && allow_connection?
          super(*args)
        else
          raise "Unit tests should not rely on a Casssandra connection. Please rewrite this spec, stub it's need for a connection, and/or add an integration spec if necessarry. See CONTRIBUTING.md for more detail."
        end
      end
    end
  end
end

module Cassandra
  include Cassie::Testing::BrokenConnection
end