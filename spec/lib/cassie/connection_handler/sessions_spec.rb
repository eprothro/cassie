RSpec.describe Cassie::ConnectionHandler::Sessions do
  let(:klass) do
    Class.new do
      include Cassie::ConnectionHandler::Sessions

      def keyspace
      end

      def cluster
      end

      def logger
        @logger ||= Logger.new('/dev/null')
        # @logger ||= Logger.new(STDOUT)
      end
    end
  end
  let(:mod){ klass.new }

  before(:each) do
    allow(mod).to receive(:keyspace){default_keyspace}
    allow(mod).to receive(:cluster){cluster}
  end
  let(:default_keyspace){ "default_keyspace" }
  let(:cluster){double("Cassandra::Cluster", connect: session)}
  let(:session){ double("Cassandra::Session", keyspace: keyspace) }
  let(:keyspace){ "explicit_keyspace" }

  describe ".sessions" do
    it "is enumerable" do
      expect(mod.sessions).to be_a_kind_of(Enumerable)
    end
  end

  describe ".session" do
    context "when a keyspace argument is passed" do
      context "when no session exists for requested keyspace" do
        it "creates session for keyspace" do
          expect(cluster).to receive(:connect).with(keyspace)

          mod.session(keyspace)
        end
        it "instruments connection opening" do
          allow(cluster).to receive(:connect).with(keyspace)

          expect(Cassie.instrumenter).to receive(:instrument).with('cassie.session.connect')

          mod.session(keyspace)
        end
      end
      context "when a session exists for requested keyspace" do
        before(:each){ mod.session(keyspace) }
        it "doesn't create another session" do
          expect(cluster).not_to receive(:connect)

          mod.session(keyspace)
        end
      end
      context "passing nil keyspace argument" do
        it "creates session for no keyspace" do
          expect(cluster).to receive(:connect).with(nil)

          mod.session(nil)
        end
      end
    end
    context "when a keyspace argument is not passed" do
      it "uses self.keyspace" do
        expect(cluster).to receive(:connect).with(default_keyspace)

        mod.session
      end
    end
  end
end

