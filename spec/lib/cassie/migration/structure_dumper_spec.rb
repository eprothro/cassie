require 'support/cql_parsing'

RSpec.describe Cassie::Migration::StructureDumper do
  let(:klass){ Cassie::Migration::StructureDumper  }
  let(:object) { klass.new }
  let(:id){ Cassandra::TimeUuid::Generator.new.now }
  let(:version_number){ '0.1.2' }
  let(:description){ 'some description' }
  let(:migrator){ 'eprothro' }
  let(:migrated_at){ Time.now - rand(10000) }
  let(:version){ Cassie::Migration::Version.new(id, version_number, description, migrator, migrated_at) }
  let(:versions){ [version] }
  before(:all) do
    Cassie::Migration::SelectVersionsQuery.include(Cassie::Testing::Fake::SessionMethods)
    Cassie::Migration::InsertVersionQuery.include(Cassie::Testing::Fake::SessionMethods)
  end

  describe "dump" do
    let(:structure){ "CREATE KEYSPACE dsfijo32809uagew WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}  AND durable_writes = true;" }
    let(:versions_insert_cql){ "INSERT into cassie_schema.versions (props) VALUES (vals);" }
    let(:buffer){ StringIO.new }
    before(:each) do
      allow(object).to receive(:stream){ buffer }
      allow(object).to receive(:structure){ structure }
      allow(object).to receive(:versions_insert_cql){ versions_insert_cql }
    end
    it "writes structure to stream" do
      object.dump
      expect(buffer.string).to start_with(structure)
    end
    it "writes versions_insert_cql to stream" do
      object.dump
      expect(buffer.string).to match(/\n\n#{Regexp.quote(versions_insert_cql)}/)
    end
    it "ends with newline" do
      object.dump
      expect(buffer.string).to end_with("\n")
    end
  end

  describe "stream" do
    it "is a file at configured path" do
    end
  end

  describe "versions" do
    let(:rows){ versions.map(&:to_h) }
    let(:versions_query) do
      q = Cassie::Migration::SelectVersionsQuery.new
      q.session.rows = rows
      q
    end
    before(:each) do
      allow(object).to receive(:versions_query) { versions_query }
    end

    it "fetches each row from the versions table" do
    end
    it "responds to version fields" do
    end

    context "when table doesn't exist" do
      before(:each) do
        allow(versions_query).to receive(:execute) do
          raise Cassandra::Errors::InvalidError.new(*(['unconfigured table foo'] + Array.new(8){nil}))
        end
      end
      it "is an empty enumerable" do
        expect(object.versions.count).to eq(0)
      end
    end
  end

  describe "versions_insert_cql" do
    before(:each) do
      allow(object).to receive(:versions){ versions }
    end

    it "inserts into version table" do
      expect(object.versions_insert_cql).to match(/^insert into versions/i)
    end
    it "inserts into 0th bucket" do
      expect(extract_cql_values(object.versions_insert_cql)['bucket']).to eq "0"
    end
    it "inserts for each element of versions" do
      expect(object.versions_insert_cql).to match(/\(bucket, #{version.members.map(&:to_s).join(', ')}\) VALUES/i)
    end
    it "inserts id" do
      expect(extract_cql_values(object.versions_insert_cql)['id']).to eq version.id.to_s
    end
    it "inserts version number as string" do
      expect(extract_cql_values(object.versions_insert_cql)['version_number']).to eq "\'#{version.version_number}\'"
    end
    it "inserts description as string" do
      expect(extract_cql_values(object.versions_insert_cql)['description']).to eq "\'#{version.description}\'"
    end
    it "inserts migrator as string" do
      expect(extract_cql_values(object.versions_insert_cql)['migrator']).to eq "\'#{version.migrator}\'"
    end
    xit "inserts migrated_at as milliseconds since epoch UTC" do
      cql_ms_int = extract_cql_values(object.versions_insert_cql)['migrated_at'].to_i
      expect(migrated_at - Time.at(cql_ms_int / 1000.0)).to be < 0.001
    end

    context "when versions are empty" do
      let(:versions){ [] }
      it "is empty" do
        expect(object.versions_insert_cql).to eq("")
      end
    end
  end
end
