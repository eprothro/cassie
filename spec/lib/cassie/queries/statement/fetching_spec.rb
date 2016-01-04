RSpec.describe Cassie::Queries::Statement::Fetching do
  let(:base_class){ Cassie::Query }
  let(:klass) do
    Class.new(base_class) do
      attr_accessor :foo

      select :resources_by_tag
    end
  end
  let(:object) do
      o = klass.new
      allow(o).to receive(:execute)
      allow(o).to receive(:result){ double(rows: rows) }
      o
  end
  let(:row){ {tag: 'tag'} }
  let(:rows){ [row] }

  describe "#fetch" do
    it "returns rows" do
      expect(object.fetch).to include(have_attributes(tag: row[:tag]))
    end
    it "assigns value if setter exists" do
      expect{
        object.fetch(foo: 'bar')
      }.to change{object.foo}.to('bar')
    end
  end
  describe "find" do
    it "returns a single row" do
      expect(object.find[:tag]).to eq(row[:tag])
    end
  end
  describe "find!" do
    it "returns a single row" do
      expect(object.find![:tag]).to eq(row[:tag])
    end
    context "when no results" do
      let(:rows){ [] }

      it "raises an exception" do
        expect{object.find!}.to raise_error(Cassie::Queries::RecordNotFound)
      end
    end
  end
end
