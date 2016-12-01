RSpec.describe Cassie::Statements::Logging::ExecuteSubscriber do
  let(:klass) do
    Cassie::Statements::Logging::ExecuteSubscriber
  end

  context "when 'cassie.cql.execution' is instrumented" do
    it "receives call" do
      expect_any_instance_of(klass).to receive(:call)
      Cassie.instrumenter.instrument("cassie.cql.execution"){}
    end
  end

  describe "#call" do
    xit "logs"
  end
end
