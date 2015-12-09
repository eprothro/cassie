RSpec.describe Cassie::Queries::PreparedStatement do
  let(:klass) do
    Class.new(Cassie::Query) do
    end
  end
  let(:object) { klass.new }

  describe ".prepare" do
    it "defaults to true" do
      Cassie.send(:remove_const, :Query)
      load 'lib/cassie/query.rb'

      expect(klass.prepare).to eq(true)
    end
    it "inherits default value from parent" do
      Cassie::Query.prepare = false
      expect(klass.prepare).to eq(false)
    end
    it "is independent of it's parent's value" do
      expect{ Cassie::Query.prepare = !Cassie::Query.prepare }
      .to_not change{ klass.prepare }
    end
  end
end
