RSpec.describe Cassie::Queries::Statement do
  let(:klass) do
    Class.new(Cassie::Query) do
      self.prepare = false
      insert :resources

      set :id
      set :field
    end
  end
  let(:object) { klass.new }
  let(:some_id){ rand(100000)}

  describe ".insert" do
    let(:klass) do
      Class.new(Cassie::Query) do
        self.prepare = false
        insert :resources do |q|
          q.set :id
          q.set :field
        end
      end
    end

    it "allows block style dsl" do
      object.id = some_id
      object.field = 'value'
      statement = object.statement
      expect(statement.cql).to eq("INSERT INTO resources (id, field) VALUES (?, ?);")
      expect(statement.params).to eq([some_id, 'value'])
    end
  end
  describe "deletion" do
    it "generates delete cql" do
      object.id = some_id
      object.field = 'value'
      statement = object.statement
      expect(statement.cql).to eq("INSERT INTO resources (id, field) VALUES (?, ?);")
      expect(statement.params).to eq([some_id, 'value'])
    end

    context "when there are no new events" do
    end
  end

  describe "paging through all events" do
  end

end
