RSpec.describe Cassie::Testing::Fake::Session do
  let(:klass) { Cassie::Testing::Fake::Session }
  let(:object) { klass.new }
  let(:statement){ double('statement') }

  describe "prepare" do
    it "returns fake prepared statement" do
      expect(object.prepare(statement)).to be_a Cassie::Testing::Fake::PreparedStatement
    end
  end

end
