RSpec.describe Cassie::Configuration::Core do
  let(:mod) do
    Module.new do
      extend Cassie::Migration::Configuration
    end
  end

  describe "paths" do
    it "has a default path for schema_structure" do
      expect(mod.paths[:schema_structure]).to eq 'db/structure.cql'
    end
    it "allows setting values" do
      expect{ mod.paths[:schema_structure] = 'db/cassie.cql' }.to change{ mod.paths[:schema_structure] }.to 'db/cassie.cql'
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