RSpec.describe Cassie::Statements::Statement do
  let(:klass) do
    Class.new(Cassie::Modification) do
      self.prepare = false
      insert_into :resources

      set :id
      set :field
    end
  end
  let(:object) { klass.new }
  let(:some_id){ rand(100000)}

  describe ".insert_into" do
    let(:klass) do
      Class.new(Cassie::Modification) do
        self.prepare = false
        insert_into :resources do |q|
          q.set :id
          q.set :field
        end

        if_not_exists
      end
    end

    it "allows block style dsl" do
      object.id = some_id
      object.field = 'value'
      statement = object.statement
      expect(statement.cql).to be_start_with("INSERT INTO resources (id, field) VALUES (?, ?)")
      expect(statement.params).to eq([some_id, 'value'])
    end
    it "supports condition" do
      expect(object.statement.cql).to be_end_with("IF NOT EXISTS;")
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
