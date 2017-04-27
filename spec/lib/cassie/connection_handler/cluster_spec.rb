RSpec.describe Cassie::ConnectionHandler::Cluster do
  let(:klass) do
    Class.new do
      include Cassie::ConnectionHandler::Cluster

      attr_accessor :keyspace

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

      context "when multiple threads access at once" do
        it "only initializes one cluster" do
          expect(Cassandra).to receive(:cluster) do |config|
            # simulate IO block so GIL yeilds to other threads
            sleep(0.001)
            cluster
          end.exactly(1).times

          threads = 2.times.map do
            Thread.new do
              mod.cluster
            end
          end
          threads.map(&:join)
        end
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

  describe "keyspace_exists?" do
    let(:cluster){ double(hosts: [], name: "", keyspaces: keyspaces) }
    let(:keyspaces){ [double(name: :foo), double(name: name)] }
    let(:name){ :bar }
    before(:each) do
      allow(Cassandra).to receive(:cluster){cluster}
    end

    it "returns true" do
      expect(mod.keyspace_exists?(name)).to eq true
    end
    it "returns false" do
      expect(mod.keyspace_exists?(:baz)).to eq false
    end
  end

    describe "keyspace_exists?" do
    let(:cluster){ double(hosts: [], name: "", keyspaces: keyspaces) }
    let(:keyspaces){ [double(name: :foo, tables: []), double(name: keyspace_name, tables: tables)] }
    let(:tables){ [double(name: :table_foo), double(name: table_name)] }
    let(:keyspace_name){ "keyspace" }
    let(:table_name){ "table" }
    before(:each) do
      allow(Cassandra).to receive(:cluster){cluster}
    end

    context "with fully qualified table name" do
      it "returns true" do
        expect(mod.table_exists?("#{keyspace_name}.#{table_name}")).to eq true
      end
      it "returns false" do
        expect(mod.table_exists?(:baz)).to eq false
      end
    end

    context "with scoped table name" do
      let(:name){ :table_bar }
      before(:each) { mod.keyspace = keyspace_name }

      it "returns true" do
        expect(mod.table_exists?(table_name)).to eq true
      end
      it "returns false" do
        expect(mod.table_exists?(:baz)).to eq false
      end
    end
  end
end