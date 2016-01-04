RSpec.describe Cassie::Queries::Instrumentation do
  let(:klass) do
    Class.new(Cassie::Query) do
    end
  end
  let(:object) { klass.new }

  describe "#execute" do
    let(:statement){ "statement" }
    let(:klass) do
      Class.new(Cassie::Query) do
      end
    end
    it "instruments the execution as `cql.execute`" do
      expect(ActiveSupport::Notifications).to receive(:instrument)
      .with('cql.execute', any_args)

      object.execute
    end
    xit "includes execution info in the payload" do
      # the way we were testing this was
      # far to integrated. try again later
    end
  end
end
