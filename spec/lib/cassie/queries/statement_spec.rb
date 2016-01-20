RSpec.describe Cassie::Queries::Statement do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
    end
  end
  let(:object) do
    o = klass.new
    allow(o).to receive(:execute)
    allow(o).to receive(:execution_successful?){ succeed? }
    o
  end

  describe ".select" do
    let(:table_name){ :some_table }
    let(:klass) do
      Class.new(Cassie::FakeQuery) do
        select :some_table
      end
    end
    it "sets the table name" do
      expect(klass.table).to eq(table_name)
    end
  end

  describe "#execute" do
  end
end