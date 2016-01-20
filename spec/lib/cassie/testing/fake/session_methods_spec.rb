RSpec.describe Cassie::Testing::Fake::SessionMethods do
  let(:klass) do
    Class.new(Cassie::Query) do
    end
  end
  let(:object) { klass.new }

  context "when extending a query class" do
    let(:klass){ super().extend(Cassie::Testing::Fake::SessionMethods) }

    describe ".session" do
      it "is a fake session" do
        expect(object.class.session).to be_a(Cassie::Testing::Fake::Session)
      end
      it "returns the same object on subsequent calls" do
        expect(object.class.session).to equal(object.class.session)
      end
    end
  end

  context "when extending a query object" do
    let(:object){ super().extend(Cassie::Testing::Fake::SessionMethods) }

    describe "#session" do
      it "is a fake session" do
        expect(object.session).to be_a(Cassie::Testing::Fake::Session)
      end
      it "returns the same object as the class" do
        expect(object.session).to equal(object.class.session)
      end
    end
    it "doesn't change the class session" do
      s = klass.session rescue nil
      expect(s).not_to be_a(Cassie::Testing::Fake::Session)
    end
  end
end
