RSpec.describe Cassie::Queries::Statement do
  let(:klass) do
    Class.new(Cassie::Query) do
    end
  end
  let(:object) { klass.new }

  describe ".select" do
    let(:table_name){ :some_table }
    let(:klass) do
      Class.new(Cassie::Query) do
        select :some_table
      end
    end
    it "sets the table name" do
      expect(klass.table).to eq(table_name)
    end
  end
end