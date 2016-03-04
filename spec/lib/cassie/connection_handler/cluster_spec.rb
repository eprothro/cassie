RSpec.describe Cassie::ConnectionHandler::Cluster do
  let(:mod) do
    Module.new do
      extend Cassie::ConnectionHandler::Cluster

      def self.configuration
      end
    end
  end

  let(:config){ {'hosts' => ['127.0.0.1'], 'port' => 9042} }

  describe ".cluster" do
    context "when none has been created" do
      before(:each) do
        allow(mod).to receive(:configuration){config}
      end
      it "creates cluster with configuration" do
        expect(Cassandra).to receive(:cluster).with(config.symbolize_keys)

        mod.cluster
      end
      it "passes symbols as configuration keys" do
        expect(Cassandra).to receive(:cluster).with(hash_including(config.symbolize_keys))

        mod.cluster
      end
    end

    context "when cluster has already been created" do
      before(:each) do
        allow(mod).to receive(:configuration){config}
        allow(Cassandra).to receive(:cluster){double("Cassandra::Cluster")}
        mod.cluster
      end
      it "doesn't create a new one" do
        expect(Cassandra).not_to receive(:cluster)
        mod.cluster
      end
    end
  end
end