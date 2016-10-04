RSpec.describe Cassie::Query do
  context "without specifying a query type" do
    let(:klass) do
      Class.new(Cassie::FakeQuery) do

        def statement
          "ALTER TABLE foo DROP updated_at;"
        end
      end
    end
    let(:object) { klass.new }

    describe ".execute" do
      it "executes on session" do
        expect{ object.execute }.to change{ object.session.query_count }.to(1)

      end
      it "executes defined statement" do
        object.execute
        expect(object.session.last_statement).to eq(object.statement)
      end
    end
  end
end
