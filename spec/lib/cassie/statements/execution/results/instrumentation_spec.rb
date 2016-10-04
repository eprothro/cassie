require 'support/instrumentation'

RSpec.describe Cassie::Statements::Results::Instrumentation do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
      select_from :test
    end
  end
  let(:object) { klass.new }

  describe "#fetch" do
    it "instruments the execution as `cassie.deserialize`" do
      event = instrumented_event_for('cassie.deserialize') do
        object.fetch.to_a
      end
      expect(event).to be_present
    end
  end
end
