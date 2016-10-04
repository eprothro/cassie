RSpec.describe Cassie::Statements::Execution::Callbacks do
  let(:klass) do
    Class.new(Cassie::FakeModification) do
    end
  end
  let(:succeed?) { true }
  let(:object) do
    o = klass.new
    allow(o).to receive(:result){ double(success?: succeed?, :deserializer= => nil) }
    o
  end

  describe ".after_failure" do
    let(:klass) do
      Class.new(Cassie::FakeModification) do
        insert_into :users
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