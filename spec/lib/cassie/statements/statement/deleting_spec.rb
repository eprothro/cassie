RSpec.describe Cassie::Statements::Statement::Deleting do
  let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new(base_class) do
      attr_accessor :foo

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
end
