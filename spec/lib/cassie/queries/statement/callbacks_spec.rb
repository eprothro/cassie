RSpec.describe Cassie::Queries::Statement::Callbacks do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
    end
  end
  let(:succeed?) { true }
  let(:object) do
    o = klass.new
    allow(o).to receive(:execution_successful?){ succeed? }
    o
  end

  describe ".after_failure" do
    let(:klass) do
      Class.new(Cassie::FakeQuery) do
        insert :users
        after_failure :foo
        def foo
        end
      end
    end

    context "when execute succeeds" do
      it "does not call object method" do
        expect(object).not_to receive(:foo)
        object.execute
      end
    end

    context "when execute fails" do
      let(:succeed?){ false }

      it "calls object method" do
        expect(object).to receive(:foo)
        object.execute
      end
    end
  end
end