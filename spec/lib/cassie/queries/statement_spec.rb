RSpec.describe Cassie::Queries::Statement do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
    end
  end
  let(:object){ klass.new }


  describe "statement" do
    context "when overridden" do
      let(:klass) do
        Class.new(Cassie::FakeQuery) do
          def statement
            "some CQL"
          end
        end
      end

      it "returns the statement" do
        expect(object.execute).to be_truthy
      end
    end
  end
end