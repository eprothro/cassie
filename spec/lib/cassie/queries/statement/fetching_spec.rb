RSpec.describe Cassie::Queries::Statement::Fetching do
  let(:base_class){ Cassie::Query }
  let(:klass) do
    Class.new(base_class) do
      attr_accessor :foo

      select :resources_by_tag
    end
  end
  let(:object) do
    object = klass.new
    object.session.next_rows = rows
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
  end
  describe "find" do
    it "returns a single row" do
      expect(object.find[:tag]).to eq(row[:tag])
    end
    it "limits the query results returned" do
      object.find

      expect(object.session.last_statement.cql).to match(/LIMIT 1/)
    end
    it "does not limit future queries" do
      object.limit = 2
      expect{object.find}.not_to change{object.limit}
    end
  end
  describe "find!" do
    it "returns a single row" do
      expect(object.find![:tag]).to eq(row[:tag])
    end
    context "when no rows" do
      let(:rows){ [] }

      it "raises an exception" do
        expect{object.find!}.to raise_error(Cassie::Queries::RecordNotFound)
      end
    end
  end
end
