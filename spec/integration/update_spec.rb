RSpec.describe Cassie::Queries::Statement do
  let(:klass) do
    Class.new(Cassie::Query) do
      self.prepare = false
      update :resources

      set :field

      where :id, :eq
    end
  end
  let(:object) { klass.new }

  describe "deletion" do
    it "generates delete cql" do
      object.id = 12345
      object.field = 'value'
      statement = object.statement
      expect(statement.cql).to eq("UPDATE resources SET field = ? WHERE id = ?;")
      expect(statement.params).to eq(['value', 12345])
    end

    context "when there are no new events" do
    end
  end

  describe "paging through all events" do
  end

end
