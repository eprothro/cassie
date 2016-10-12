RSpec.describe Cassie do
  let(:klass) do
    Class.new(Cassie::Query) do
      self.prepare = false
      select_from :resources

      where :id, :eq
    end
  end
  let(:object) { klass.new }

  describe ".where" do
    it "sets where clause" do
      object.id = 12345
      statement = object.statement
      expect(statement.cql).to eq("SELECT * FROM resources WHERE id = ? LIMIT 500;")
      expect(statement.params).to eq([12345])
    end
  end

  describe ".select" do
    it "sets the table name" do
      expect(klass.table).to eq(:resources)
    end
  end
end
