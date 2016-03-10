RSpec.describe Cassie::Logger do
  let(:klass) { Cassie }
  let(:buffer){ StringIO.new }
  let(:logger){ Logger.new(buffer) }
  let(:message){ 'some logger message' }

  describe ".logger" do
    it "returns logger" do
    end
  end

  describe ".logger=" do
    before(:each) { klass.logger = logger }
    it "sets logger" do
      logger.debug(message)
      expect(buffer.string).to match(message)
    end
    context "when setting nil" do
      let(:logger){ nil }
      it "logs to dev/null" do
        dev = klass.logger.instance_variable_get(:@logdev)
        expect(dev.filename).to eq('/dev/null')
      end
    end
  end
end
