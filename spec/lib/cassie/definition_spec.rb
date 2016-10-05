RSpec.describe Cassie::Definition do
  let(:klass) do
    Class.new(Cassie::FakeDefinition) do

      def statement
        %(
          CREATE TABLE records_by_owner (
            owner_id timeuuid,
            record_id timeuuid,
            record text,
            PRIMARY KEY(id, record_id)
          ) WITH CLUSTERING ORDER BY (record_id ASC);
         )
      end
    end
  end
  let(:object) { klass.new }

  describe "execute" do
    it "executes the statement" do
      expect(object.session).to receive(:execute).with(object.statement, anything())
      object.execute
    end
  end
end