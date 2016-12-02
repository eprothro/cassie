RSpec.describe Cassie::Statements::Statement::Deleting do
  let(:base_class){ Cassie::FakeModification }
  let(:klass) do
    Class.new(base_class) do
      delete_from :resources_by_tag
    end
  end
  let(:object) do
      o = klass.new
      allow(o).to receive(:execute)
      allow(o).to receive(:result){ double(empty?: true, rows: []) }
      o
  end
  let(:resource){ double }
  let(:column){ 'some_column' }

  describe "#column" do
    it "adds string to columns" do
      expect{klass.column(column)}.to change{klass.columns}.to([column])
    end
    it "adds symbol selector" do
      expect{klass.column(column.to_sym)}.to change{klass.columns}.to([column])
    end
  end

  describe "build_delete_clause" do
    context "with no columns" do
      it "is emtpy" do
        expect(object.send(:build_delete_clause)).to eq("")
      end
    end
    context "with multiple columns" do
      it "is joins with commas" do
        allow(object).to receive(:columns){['foo', 'bar[baz]']}
        expect(object.send(:build_delete_clause)).to eq("foo, bar[baz]")
      end
    end
  end
end
