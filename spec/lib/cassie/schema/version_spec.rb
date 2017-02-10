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

  describe "==" do
    it "matches for same version number" do
      expect(klass.new('0.1.2') == klass.new('0.1.2.0')).to be true
    end
    it "doesn't match for different version number" do
      expect(klass.new('0.1.2') == klass.new('0.1.3')).to be false
    end
  end

  describe "eql?" do
    it "matches for same version number" do
      expect(klass.new('0.1.2').eql?(klass.new('0.1.2.0'))).to be true
    end
    it "doesn't match for different version number" do
      expect(klass.new('0.1.2').eql?(klass.new('0.1.3'))).to be false
    end
  end

  describe "hash" do
    it "matches for same version number" do
      expect(klass.new('0.1.2').hash).to eq(klass.new('0.1.2.0').hash)
    end
    it "doesn't match for different version number" do
      expect(klass.new('0.1.2').hash).not_to eq(klass.new('0.1.3').hash)
    end
  end

  describe "union with |" do
    it "doesn't duplicate" do
      expect([klass.new('1')] | [klass.new('1')]).to eq([klass.new('1')])
    end
    it "joins members" do
      expect([klass.new('1')] | [klass.new('2')]).to eq([klass.new('1'), klass.new('2')])
    end
  end

  describe "next" do
    it "adds 1 to patch" do
      expect(object.next.number).to eq("0.1.3.0")
    end
    it "adds 1 to minor" do
      expect(object.next(:minor).number).to eq("0.2.0.0")
    end
    it "adds 1 to major" do
      expect(object.next(:major).number).to eq("1.0.0.0")
    end
    it "adds 1 to build" do
      expect(object.next(:build).number).to eq("0.1.2.1")
    end
  end

  describe "migration_class_name" do
    it "always outputs 4 parts" do
      expect(object.migration_class_name).to eq("Migration_0_1_2_0")
    end
  end
end
