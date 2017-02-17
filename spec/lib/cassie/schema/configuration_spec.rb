RSpec.describe Cassie::Configuration::Core do
  let(:mod) do
    Module.new do
      extend Cassie::Schema::Configuration
    end
  end

  describe "paths" do
    it "has a default path for schema_structure" do
      expect(mod.paths[:schema_file]).to eq 'db/cassandra/schema.rb'
    end
    it "allows setting values" do
      expect{ mod.paths[:schema_file] = 'db/cassie.rb' }.to change{ mod.paths[:schema_file] }.to 'db/cassie.rb'
    end
  end
  describe "schema_keyspace" do
    it "defaults to cassie_schema" do
      expect(mod.schema_keyspace).to eq "cassie_schema"
    end
  end
  describe "schema_keyspace=" do
    it "sets value" do
      expect{ mod.schema_keyspace = 'test' }.to change{ mod.schema_keyspace }.to "test"
    end
  end
  describe "versions_table" do
    it "defaults to cassie_schema" do
      expect(mod.versions_table).to eq 'versions'
    end
  end
  describe "versions_table=" do
    it "sets value" do
      expect{ mod.versions_table = 'test' }.to change{ mod.versions_table }.to "test"
    end
  end
end