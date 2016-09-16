RSpec.describe Cassie do
  let(:klass) do
    Class.new(Cassie::Modification) do
      self.prepare = false
      delete_from :resources

      where :id, :eq

      if_exists
    end
  end
  let(:object) { klass.new }

  describe "deletion" do
    it "generates delete cql" do
      object.id = 12345
      statement = object.statement
      expect(statement.cql).to be_start_with("DELETE FROM resources WHERE id = ?")
      expect(statement.params).to eq([12345])
    end

    it "supports condition" do
      expect(object.statement.cql).to be_end_with("IF EXISTS;")
    end
  end
end
