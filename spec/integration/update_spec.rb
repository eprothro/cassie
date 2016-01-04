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
  let(:some_id){ rand(10000) }

  describe ".update" do
    let(:klass) do
      Class.new(Cassie::Query) do
        self.prepare = false
        update :resources do |q|
          q.where :id, :eq
          q.set :field
        end
      end
    end

    it "allows block style dsl" do
      object.id = some_id
      object.field = 'value'
      statement = object.statement
      expect(statement.cql).to eq("UPDATE resources SET field = ? WHERE id = ?;")
      expect(statement.params).to eq(['value', some_id])
    end
  end
  describe "deletion" do
    it "generates delete cql" do
      object.id = some_id
      object.field = 'value'
      statement = object.statement
      expect(statement.cql).to eq("UPDATE resources SET field = ? WHERE id = ?;")
      expect(statement.params).to eq(['value', some_id])
    end

    context "when there are no new events" do
    end
  end

  describe "paging through all events" do
  end

end
