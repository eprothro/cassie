require 'support/resource'

RSpec.describe Cassie::Queries::Statement::Loading do
  let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new(base_class) do
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

  context "when overriding build_resource" do
    let(:klass) do
      Class.new(base_class) do

        select :resources_by_tag

        def build_resource(row)
          Resource.new
        end
      end
    end

    it "returns expected class" do
      expect(object.fetch).to include(a_kind_of Resource)
    end
  end
end
