RSpec.describe Cassie::ConnectionHandler::Cluster do
  let(:klass) do
    Class.new do
      include Cassie::ConnectionHandler::Cluster

      def configuration
      end
      def logger
        @logger ||= Logger.new('/dev/null')
        # @logger ||= Logger.new(STDOUT)
      end
    end
  end
  let(:mod){ klass.new }
  let(:cluster){ double(hosts: [], name: "") }

  let(:config){ {'hosts' => ['127.0.0.1'], 'port' => 9042} }

  describe ".cluster" do
    context "when none has been created" do
      before(:each) do
        allow(mod).to receive(:configuration){config}
      end
      it "creates cluster with configuration" do
        expect(Cassandra).to receive(:cluster).with(config.symbolize_keys){cluster}

        mod.cluster
      end
      it "passes symbols as configuration keys" do
        expect(Cassandra).to receive(:cluster).with(hash_including(config.symbolize_keys)){cluster}

        mod.cluster
      end
      it "logs connection timing" do
        allow(Cassandra).to receive(:cluster).with(config.symbolize_keys){cluster}

        expect(Cassie.instrumenter).to receive(:instrument).with('cassie.cluster.connect')

        mod.cluster
      end
    end

    context "when cluster has already been created" do
      before(:each) do
        allow(mod).to receive(:configuration){config}
        allow(Cassandra).to receive(:cluster){cluster}
        mod.cluster
      end
      it "doesn't create a new one" do
        expect(Cassandra).not_to receive(:cluster)
        mod.cluster
      end
    end
  end
end