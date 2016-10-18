RSpec.describe Cassie::Statements::Statement::Idempotency do
  let(:klass) do
    Class.new do
      include Cassie::Statements::Statement::Idempotency
    end
  end
  let(:object) { subclass.new }

  describe ".idempotent?" do
    context "when no idempotentcy has been set" do
      it "is false" do
        expect(klass.idempotent?).to eq(false)
      end
    end
    context "when idempotentcy has been set" do
      before(:each){ klass.idempotent(true) }
      it "is true" do
        expect(klass.idempotent?).to eq(true)
      end
    end
  end
end
