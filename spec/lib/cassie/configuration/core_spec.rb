RSpec.describe Cassie::Configuration::Core do
  let(:mod) do
    Module.new do
      extend Cassie::Configuration::Core

      def self.cluster_configurations
      end
    end
  end

  before(:each) do
    allow(mod).to receive(:cluster_configurations){configurations}
  end
  let(:configurations){ {development: 'dev config', test: 'test config', production: 'prod config'}.with_indifferent_access }
  let(:alt_configurations){ {development: 'alt dev config', test: 'alt test config', production: 'alt prod config'}.with_indifferent_access }
  let(:alt_config){ alt_configurations.values.first }

  describe ".configurations" do
    context "when not defined" do
      it "loads  configuration" do
        expect(mod).to receive(:cluster_configurations)

        mod.configurations
      end
    end
    context "when assigned" do
      before(:each){ mod.configurations }
      it "does not load_configuration" do
        expect(mod).not_to receive(:cluster_configurations)

        mod.configurations
      end
    end
  end

  describe ".configurations=" do
    context "when configuration has been set" do
      before(:each){ mod.configuration = alt_config }
      it "warns" do
        expect{mod.configurations = {}}.to output(/WARNING/).to_stdout
      end
    end
  end

  describe ".configuration" do
    context "when configuration has not been set" do
      it "returns config for the current env" do
        expect(mod.configuration).to eq(configurations[:development])
      end
      context "when env is not set" do
        it "returns nil" do
          mod.env = ""
          expect(mod.configuration).to eq(nil)
        end
      end
    end
    context "when configuration has been set" do
      it "returns the configuration" do
        expect{mod.configuration = alt_config}.to change{mod.configuration}.to(alt_config)
      end
      it "does not access configurations" do
        mod.configuration = alt_config

        expect(mod).not_to receive(:configurations)
        mod.configuration
      end
    end
  end

  describe ".env" do
    it "defaults to development" do
      expect(mod.env).to eq("development")
    end
    it "prefers CASSANDRA_ENV over RACK_ENV" do
      allow(ENV).to receive(:[]).with('CASSANDRA_ENV'){'a'}
      allow(ENV).to receive(:[]).with('RACK_ENV'){'b'}
      expect(mod.env).to eq("a")
    end
    it "supports RACK_ENV" do
      allow(ENV).to receive(:[]).with('CASSANDRA_ENV'){nil}
      allow(ENV).to receive(:[]).with('RACK_ENV'){'b'}
      expect(mod.env).to eq("b")
    end
  end

  describe ".env=" do
    it "doesn't allow symbol assignment" do
      expect{mod.env = :development}.to raise_error
    end
    it "overrides CASSANDRA_ENV and RACK_ENV" do
      allow(ENV).to receive(:[]).with('CASSANDRA_ENV'){'a'}
      allow(ENV).to receive(:[]).with('RACK_ENV'){'b'}
      mod.env = 'c'
      expect(mod.env).to eq('c')
    end
  end

  describe ".keyspace" do
    let(:default_keyspace){ 'default_keyspace' }

    context  "when not defined" do
      it "pulls from configuration['keyspace']" do
        allow(mod).to receive(:configuration){{keyspace: default_keyspace}}
        expect(mod.keyspace).to eq(default_keyspace)
      end
    end
    context "when already assigned" do
      let(:keyspace){ 'keyspace' }
      before(:each){ mod.keyspace = keyspace }

      it "does not pull from Cassie Configuration" do
        expect(mod).not_to receive(:configuration)
        mod.keyspace
      end
      it "returns the assigned keyspace" do
        expect(mod.keyspace).to eq(keyspace)
      end

      context "when nil" do
        let(:keyspace){ nil }
        it "does not pull from Cassie Configuration" do
          expect(mod).not_to receive(:configuration)
          mod.keyspace
        end
        it "returns the assigned keyspace" do
          expect(mod.keyspace).to eq(keyspace)
        end
      end
    end
  end

  describe ".keyspace=" do
    it "invalides the right caches"
  end
end