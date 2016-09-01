RSpec.describe Cassie::Testing::Fake::PreparedStatement do
  let(:klass) { Cassie::Testing::Fake::PreparedStatement }
  let(:object) { klass.new(statement) }
  let(:statement){ Cassandra::Statements::Simple.new(prepared_cql, prepared_arguments) }
  let(:prepared_cql){ "select * from testing where id = ?;" }
  let(:prepared_arguments){ [123] }
  let(:arguments){ [456] }

  describe "bind" do
    it "returns statement with params that match arguments" do
      bound = object.bind(arguments)
      expect(bound.params).to eq(arguments)
    end
  end

end
