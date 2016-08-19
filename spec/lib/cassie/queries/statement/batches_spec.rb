RSpec.describe Cassie::Queries::Statement::Batches do
  let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new(base_class) do
      attr_accessor :foo

      select :resources_by_tag
    end
  end
  let(:object) do
    object = klass.new
    object.session.rows = rows
    object
  end
  let(:rows){ [row] }
  let(:row){ {tag: 'tag'} }

  describe "#fetch_in_batches" do
    it "assigns value if setter exists" do

    end
  end
end
