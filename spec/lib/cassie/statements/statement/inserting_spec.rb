RSpec.describe Cassie::Statements::Statement::Inserting do
  let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new(base_class) do
      delete_from :resources_by_id
    end
  end
  let(:object) { klass.new }
end
