RSpec.describe Cassie::Statements::Statement::Limiting do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
      select_from :users
    end
  end
  let(:object){ klass.new }
  let(:limit){ 1 }

  describe "#statement" do
    context "when no limit has been set" do
      it "has no limit clause" do
        expect(object.statement.cql).not_to match(/LIMIT/)
      end
    end
    context "when class has limit" do
      let(:klass) do
        Class.new(Cassie::FakeQuery) do
          select_from :users

          limit 1
        end
      end
      it "includes limit clause" do
        expect(object.statement.cql).to match(/LIMIT #{limit}/)
      end
    end
  end
end