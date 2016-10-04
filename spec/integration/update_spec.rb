RSpec.describe Cassie::Statements::Statement do
  let(:klass) do
    Class.new(Cassie::Modification) do
      self.prepare = false
      update :resources

      set :field

      where :id, :eq
    end
  end
  let(:object) { klass.new }
  let(:some_id){ rand(10000) }

  describe ".update" do
    let(:klass) do
      Class.new(Cassie::Modification) do
        self.prepare = false
        update :resources do |q|
          q.where :id, :eq
          q.set :field
        end

        if_exists
      end
    end

    it "allows block style dsl" do
      object.id = some_id
      object.field = 'value'
      statement = object.statement
      expect(statement.cql).to be_start_with("UPDATE resources SET field = ? WHERE id = ?")
      expect(statement.params).to eq(['value', some_id])
    end
    it "supports condition" do
      expect(object.statement.cql).to be_end_with("IF EXISTS;")
    end
  end
end
