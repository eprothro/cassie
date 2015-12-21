RSpec.describe Cassie::Queries::Statement::Loading do
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
  let(:row){ {tag: 'some_tag'} }
  let(:rows){ [row] }

  describe "#fetch" do
    it "returns an object with a fetcher method for row attributes" do
      expect(object.fetch.first.tag).to eq(row[:tag])
    end
  end
end
