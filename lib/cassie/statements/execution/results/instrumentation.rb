module Cassie::Statements::Results
  module Instrumentation

    protected

    def records
      Cassie.instrumenter.instrument("cassie.deserialize") do |payload|
        records = super
        payload[:count] = records.count if records.respond_to?(:count)
        records
      end
    end
  end
end