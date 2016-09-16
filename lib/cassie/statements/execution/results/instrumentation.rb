module Cassie::Statements::Results
  module Instrumentation

    protected

    def records
      instrumenter.instrument("cassie.deserialize") do |payload|
        records = super
        payload[:count] = records.count if records.respond_to?(:count)
        records
      end
    end

    def instrumenter
      Cassie::Statements.instrumenter
    end
  end
end