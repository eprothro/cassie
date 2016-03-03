require 'yaml'

RSpec.describe Cassie::Configuration::Loading do
  let(:mod) do
    Module.new do
      extend Cassie::Configuration::Loading

      def self.paths
        @paths ||= {}
      end
    end
  end
  let(:config_path){ File.expand_path("../cassandra.yml", __FILE__) }
  let(:config){ {"development" => 'development_config'} }
  before(:each) do
    mod.paths["cluster_configurations"] = config_path
  end

  describe ".cluster_configurations" do
    context "when backend exists" do
      before(:each) do
        File.write(config_path, YAML.dump(config))
      end
      after(:each) do
        File.delete(config_path)
      end
      it "returns hash from backend" do
        expect(mod.cluster_configurations).to eq(config)
      end
    end
    context "when backend does not exist" do
      it "raises" do
        expect{mod.cluster_configurations}.to raise_error(Cassie::Configuration::MissingClusterConfigurations)
      end
    end
  end

  describe "MissingClusterConfigurations" do
    let(:klass){ Cassie::Configuration::MissingClusterConfigurations }
    let(:path){ "some_path.yml" }
    let(:generation_instrucitons){ "some instruction" }
    it "displays path in message" do
      expect(klass.new(path).message).to include(path)
    end
    it "allows instruction overriding" do
      class Cassie::Configuration::MissingClusterConfigurations
        def generation_instructions
          "some instruction"
        end
      end

      expect(klass.new(path).message).to include(generation_instrucitons)
    end
  end
end