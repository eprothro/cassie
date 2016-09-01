RSpec.describe Cassie::Statements::Execution::Fetching do
  let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new(base_class) do
      attr_accessor :foo

      select_from :resources_by_tag
    end
  end
  let(:object) do
    object = klass.new
    object.session.rows = rows
    object
  end
  let(:rows){ [row] }
  let(:row){ {tag: 'tag'} }

  describe "#fetch" do
    it "returns rows" do
      expect(object.fetch).to include(have_attributes(tag: row[:tag]))
    end
    it "assigns value if setter exists" do
      expect{
        object.fetch(foo: 'bar')
      }.to change{object.foo}.to('bar')
    end

    context "when there are no results" do
      let(:rows){ [].to_enum }
      it "returns an empty enumerable" do
        expect(object.fetch(foo: 'bar').count).to eq(0)
      end
    end
  end

  describe "fetch_first" do
    it "returns a single row" do
      expect(object.fetch_first[:tag]).to eq(row[:tag])
    end
    it "assigns value if setter exists" do
      expect{
        object.fetch_first(foo: 'bar')
      }.to change{object.foo}.to('bar')
    end
    it "limits the query results returned" do
      object.fetch_first

      expect(object.session.last_statement.cql).to match(/LIMIT 1/)
    end
    it "does not limit future queries" do
      object.limit = 2
      expect{object.fetch_first}.not_to change{object.limit}
    end
  end

  describe "fetch_first!" do
    it "returns a single row" do
      expect(object.fetch_first![:tag]).to eq(row[:tag])
    end
    context "when no rows" do
      let(:rows){ [] }

      it "raises an exception" do
        expect{object.fetch_first!}.to raise_error(Cassie::Statements::RecordNotFound)
      end
    end
  end
end
