require 'support/instrumentation'

RSpec.describe Cassie::Queries::Instrumentation::Loading do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
      select :test
    end
  end
  let(:object) { klass.new }

  describe "#fetch" do
    it "instruments the execution as `cassie.building_resources`" do
      event = instrumented_event_for('cassie.building_resources') do
        object.fetch
      end

      expect(event).to be_present
    end
  end
end
