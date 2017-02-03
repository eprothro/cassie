RSpec.describe Cassie::Schema::Version do
  let(:klass){ Cassie::Schema::Version  }
  let(:object) { klass.new(number) }
  let(:number){ '0.1.2' }

  describe "number" do
    it "drops leading 0s" do
      expect(klass.new('00.001.1.0').number).to eq('0.1.1.0')
    end
    it "always has 4 parts" do
      expect(klass.new('00.001.1').number).to eq('0.1.1.0')
    end
  end

  describe "comparing" do
    it "compares to version" do
      expect(klass.new('0.1.2') < klass.new('0.1.3')).to eq(true)
    end
    it "compares to string" do
      expect(klass.new('0.1.2') < '0.2').to eq(true)
    end
  end

  describe "sorting" do
    it "sorts" do
      ar = [klass.new('0.1.3'), klass.new('0.1.2')]
      ar.sort!
      expect(ar.first.number).to eq('0.1.2.0')
      expect(ar.last.number).to eq('0.1.3.0')
    end
  end

  describe "next_version" do
    it "adds 1 to patch" do
      expect(object.next_version.number).to eq("0.1.3.0")
    end
    it "adds 1 to minor" do
      expect(object.next_version(:minor).number).to eq("0.2.0.0")
    end
    it "adds 1 to major" do
      expect(object.next_version(:major).number).to eq("1.0.0.0")
    end
    it "adds 1 to build" do
      expect(object.next_version(:build).number).to eq("0.1.2.1")
    end
  end
end