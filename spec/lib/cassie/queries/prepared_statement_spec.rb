RSpec.describe Cassie::Queries::PreparedStatement do
  let(:base_class){ Cassie::Query }
  let(:klass) do
    Class.new(base_class) do
    end
  end
  let(:object) { klass.new }

  before(:each){ @original = base_class.prepare }
  after(:each){ base_class.prepare = @original }

  describe ".prepare" do
    it "defaults to true" do
      expect(klass.prepare).to eq(true)
    end
    it "inherits default value from parent" do
      base_class.prepare = false
      expect(klass.prepare).to eq(false)
    end
    it "is independent of it's parent's value" do
      expect{ base_class.prepare = !base_class.prepare }
      .to_not change{ klass.prepare }
    end
  end
end
