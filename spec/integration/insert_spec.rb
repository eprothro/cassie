RSpec.describe Cassie::Queries::Statement, :only do
  let(:klass) do
    Class.new(Cassie::Query) do
      self.prepare = false
      insert :resources

      set :id
      set :field
    end
  end
  let(:object) { klass.new }

  describe "deletion" do
    it "generates delete cql" do
      object.id = 12345
      object.field = 'value'
      statement = object.statement
      expect(statement.cql).to eq("INSERT INTO resources (id, field) VALUES (?, ?);")
      expect(statement.params).to eq([12345, 'value'])
    end

    context "when there are no new events" do
    end
  end

  describe "paging through all events" do
  end

end
