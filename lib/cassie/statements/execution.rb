module Cassie::Statements
  # Execution support for Cassandra Statements
  #
  # Requires the following methods be provided:
  # * +statement+
  #   * CQL +String+ or +Cassandra::Statements:Statement+ executable by a +Cassandra::Session+
  # * +session+
  #   * A +Cassandra::Session+ scoped to an appropriate keyspace
  module Execution
    require_relative 'execution/errors'
    require_relative 'execution/consistency'
    require_relative 'execution/callbacks'
    require_relative 'execution/results'
    require_relative 'execution/partition_linking'
    require_relative 'execution/instrumentation'

    # @!visibility private
    # @!parse include Consistency
    # @!parse include Callbacks
    # @!parse include PartitionLinking
    # @!parse include Instrumentation
    def self.included(base)
      base.instance_eval do
        # The result from execution.
        # Includes all attributes and methods available from
        # a +Cassandra::Result+
        # @return [Cassie::Statements::Results::Result] A decorated +Cassandra::Result+ object
        attr_reader :result

        include Consistency
        include Callbacks
        include PartitionLinking
        include Instrumentation
      end
      base.extend ClassMethods
    end

    # @!parse extend ClassMethods
    module ClassMethods
      def inherited(subclass)
        subclass.result_class = result_class if defined?(@result_class)
        super
      end
      # The class to use for decorating the +Cassandra::Result+
      # @!parse attr_accessor :result_class
      def result_class
        return @result_class if defined?(@result_class)
        Cassie::Statements::Results::Result
      end

      def result_class=(val)
        @result_class = val
      end
    end

    # Executes the statment and populates result
    # @return [Boolean] indicating a successful execution or not
    def execute
      @result = result_class.new(session.execute(statement, execution_options), result_opts)
      result.success?
    end

    # Same as {#execute}. Raises if not succesfull.
    # @return [Boolean] true if sucessful
    # @raise [Cassie::Statements::ExecutionError] if the result was not sucessful, see {Cassie::Statements::Results::Core#success?}
    def execute!
      execute || (raise Cassie::Statements::ExecutionError.new(result))
    end

    # The session exection options configured for statement execution
    # @return [Hash{Symbol => Object}]
    def execution_options
      {}.tap do |opts|
        # @todo rework consistency module to be more
        #      abstract implementation for all execution options
        opts[:consistency] = consistency if consistency
        opts[:paging_state] = paging_state if respond_to?(:paging_state) && paging_state
        opts[:page_size] = stateless_page_size if respond_to?(:stateless_page_size) && stateless_page_size
      end
    end

    protected

    def result_class
      self.class.result_class
    end

    def result_opts
      {}
    end

    private

    # Ensures that +clone+ and +dup+ drops the reference to the
    # result object. The cloned object should be able to mutate
    # the statement and execute without affecting the original
    # objecthe resulting object or its results.
    def initialize_copy(other)
      super
      @result = nil
    end
  end
end