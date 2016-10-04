module Cassie::Statements
  module Execution
    require_relative 'execution/consistency'
    require_relative 'execution/callbacks'
    require_relative 'execution/results'
    require_relative 'execution/instrumentation'

    extend ActiveSupport::Concern
    included do
      attr_reader :result

      include Consistency
      include Callbacks
      include Instrumentation
    end

    # Executes the statment, populates result
    # returns true or false indicating a successful execution or not
    def execute
      @result = result_class.new(session.execute(statement, execution_options), result_opts)
      result.success?
    end

    def execution_options
      {}.tap do |opts|
        #TODO: rework consistency module to be more
        #      abstract implementation for all execution options
        opts[:consistency] = consistency if consistency
        opts[:paging_state] = paging_state if respond_to?(:paging_state) && paging_state
        opts[:page_size] = stateless_page_size if respond_to?(:stateless_page_size) && stateless_page_size
      end
    end

    protected

    def result_class
      Cassie::Statements::Results::Result
    end

    def result_opts
      {}
    end
  end
end