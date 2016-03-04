RSpec.describe Cassie::FakeQuery do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
    end
  end
  let(:object) { klass.new }

  describe '#session' do
    it "is a fake session" do
      expect(object.session).to be_a(Cassie::Testing::Fake::Session)
    end
  end
end
