require_relative 'consistency'

module Cassie::Queries::Statement
  module Execution
    extend ActiveSupport::Concern

    included do
      include Consistency
    end

    # Executes the statment, populates result
    # returns true or false indicating a successful execution or not
    def execute
      @result = session.execute(statement, execution_options)
      execution_successful?
    end

    def execution_options
      {}.tap do |opts|
        #TODO: rework consistency module to be more
        #      abstract implementation for all execution options
        opts[:consistency] = consistency if consistency
      end
    end

    protected

    def execution_successful?
      #TODO: rethink this, it knows too much
      raise "execution not complete, no results to parse" unless result

      # empty select
      return true if result.empty?

      # failed upsert
      return false if (!result.rows.first["[applied]"].nil?) && (result.rows.first["[applied]"] == false)

      true
    end
  end
end