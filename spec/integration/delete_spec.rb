RSpec.describe Cassie::Queries::Statement do
  let(:klass) do
    Class.new(Cassie::Query) do
      self.prepare = false
      delete :resources

      where :id, :eq
    end
  end
  let(:object) { klass.new }

  describe "deletion" do
    it "generates delete cql" do
      object.id = 12345
      statement = object.statement
      expect(statement.cql).to eq("DELETE FROM resources WHERE id = ?;")
      expect(statement.params).to eq([12345])
    end

    context "when there are no new events" do
    end
  end

  describe "paging through all events" do
  end

end
