RSpec.describe Cassie::Testing::Fake::SessionMethods do
  let(:klass) do
    Class.new do
      include Cassie::Connection
    end
  end
  let(:object) { klass.new }

  context "when appending a class with a keyspace" do
    let(:klass) do
      Class.new(Cassie::Query) do
        include Cassie::Connection
        include Cassie::Testing::Fake::SessionMethods
      end
    end

    describe ".session" do
      it "is a fake session" do
        expect(object.session).to be_a(Cassie::Testing::Fake::Session)
      end
      it "returns the same object on subsequent calls" do
        # @todo reworking test harnessing
        # based on new Configuration and Connection architecture
        expect(object.session).to equal(object.session)
      end
    end
  end

  context "when appending an object with a keyspace" do
    let(:object){ super().extend(Cassie::Testing::Fake::SessionMethods) }

    describe "#session" do
      it "is a fake session" do
        expect(object.session).to be_a(Cassie::Testing::Fake::Session)
      end
    end
    it "doesn't change the class session" do
      s = klass.session rescue nil
      expect(s).not_to be_a(Cassie::Testing::Fake::Session)
    end
  end
end
