RSpec.describe Cassie::Query do
  let(:klass) do
    Class.new(Cassie::Query) do
    end
  end
  let(:object) { klass.new }

  describe ".cql" do
    let(:statement){ "statement" }
    let(:klass) do
      Class.new(Cassie::Query) do
        cql "statement"
      end
    end
    it "sets the statement for the class" do
      expect(klass.statement).to eq(statement)
    end
  end
  describe ".statement" do
    context "when no cql has been set" do
      it "returns nil" do
        expect(klass.statement).to be_nil
      end
    end
  end
end