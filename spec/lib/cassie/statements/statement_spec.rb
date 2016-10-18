RSpec.describe Cassie::Statements::Statement do
  let(:klass) do
    Class.new do
      include Cassie::Statements::Statement
      self.prepare = false
    end
  end
  let(:object){ klass.new }


  describe "statement" do
    
    it "passes idempotency along" do
      expect{ object.idempotent = true }.to change{
        object.statement.idempotent?
      }.to(true)
    end
    
    it "passes type hints along" do
      object.type_hints = {}
      expect_any_instance_of(Cassandra::Statements::Simple).to receive(:initialize).with(object.cql, object.params, object.type_hints, object.idempotent)
      
      object.statement
    end
    
    context "when overridden" do
      let(:klass) do
        Class.new(Cassie::FakeQuery) do
          def statement
            "some CQL"
          end
        end
      end

      it "returns the statement" do
        expect(object.statement).to eq("some CQL")
      end
    end
  end
end