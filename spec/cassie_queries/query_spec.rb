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
end