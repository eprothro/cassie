RSpec.describe Cassie::Statements::Execution::Instrumentation do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
      select_from :test
    end
  end
  let(:object) { klass.new }

  describe "#execute" do
    it "instruments the execution as `cassie.cql.execution`" do
      event = instrumented_event_for('cassie.cql.execution') do
        object.execute
      end

      expect(event).to be_present
    end
    xit "includes execution info in the payload" do
      # the way we were testing this was
      # far to integrated. try again later
    end
  end
end
