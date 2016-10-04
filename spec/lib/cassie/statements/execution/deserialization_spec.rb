require 'support/resource'

RSpec.describe Cassie::Statements::Execution::Deserialization do
  let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new(base_class) do
      select_from :resources_by_tag
    end
  end
  let(:object) { klass.new }
  let(:row){ {'tag' => 'some_tag'} }
  let(:rows){ [row] }
  before(:each){ object.session.rows = rows }

  describe "#fetch" do
    it "returns an object with a fetcher method for row attributes" do
      expect(object.fetch.first.tag).to eq(row['tag'])
    end

    it "returns a query result object" do
      expect(object.fetch).to be_a(Cassie::Statements::Results::QueryResult)
    end
  end

  context "when providing a build record method" do
    let(:klass) do
      Class.new(base_class) do

        select_from :resources_by_tag

        def build_result(hash)
          Resource.new
        end
      end
    end

    it "returns expected class" do
      expect(object.fetch).to include(a_kind_of Resource)
    end
  end

  context "when providing a build_results method" do
    let(:klass) do
      Class.new(base_class) do

        select_from :resources_by_tag

        def build_results(hashes)
          [1]
        end
      end
    end

    it "returns custom deserialization" do
      expect(object.fetch).to include(1)
      expect(object.fetch.to_a).to eq([1])
    end
  end
end
