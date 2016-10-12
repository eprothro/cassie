RSpec.describe Cassie::Connection do
  let(:klass) do
    Class.new do
      include Cassie::Connection
    end
  end
  let(:object) { klass.new }
  let(:keyspace) { 'keyspace' }
  let(:alt_keyspace) { 'alt_keyspace' }
  before(:each){
    allow(Cassie).to receive(:keyspace){ keyspace }
  }

  describe "#session" do
    it "passes keyspace to class session" do
      allow(object).to receive(:keyspace){ keyspace }
      expect(Cassie).to receive(:session).with(keyspace)

      object.session
    end
    it "passes nil keyspace to class session" do
      object.keyspace = nil
      expect(Cassie).to receive(:session).with(nil)

      object.session
    end
  end

  describe ".keyspace" do
    context "when not defined" do
      it "falls back to Cassie value" do
        expect(Cassie).to receive(:keyspace){keyspace}
        expect(object.keyspace).to eq(keyspace)
      end
    end
    context "when defined" do
      it "returns value" do
        expect{object.keyspace = alt_keyspace}.to change{object.keyspace}.to(alt_keyspace)
      end
      it "returns nil" do
        expect{object.keyspace = nil}.to change{object.keyspace}.to(nil)
      end
    end
  end

  describe ".keyspace(val)" do
    it "calls class setter" do
      expect(klass).to receive(:keyspace=).with(nil)
      klass.keyspace(nil)
    end
  end

  describe "#keyspace" do
    context "when not defined" do
      it "falls back to class value" do
        expect(klass).to receive(:keyspace){keyspace}
        expect(object.keyspace).to eq(keyspace)
      end
    end
    context "when defined" do
      before(:each){ object.keyspace = alt_keyspace }
      it "returns value" do
        expect(object.keyspace).to eq(alt_keyspace)
      end
      it "doesn't fall back to class value" do
        expect(klass).not_to receive(:keyspace)
      end
    end
  end
end