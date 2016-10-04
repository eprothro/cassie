require 'support/resource'

RSpec.describe Cassie::Statements::Results::Querying do
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
end
