# Break cassandra cluster for unit specs
# which should not rely on database
# db_spec_helper undoes this patch
# for spec runs that should require db
module Cassie::Testing
  module BrokenAbort
    def abort(*args)
      if respond_to?(:allow_abort?) && allow_abort?
          super(*args)
        else
          raise "Unit tests should not rely on aborting the process. Please rewrite this spec, stub its need for abort, and/or add an integration spec if necessarry. See CONTRIBUTING.md for more detail."
        end
    end

    def fail(*args)
      abort(*args)
    end
  end
end

require 'cassie/tasks'
module Cassie::Tasks::IO
  include Cassie::Testing::BrokenAbort
end