require 'support/cql_parsing'

RSpec.describe Cassie::Schema::StructureDumper do
  let(:klass){ Cassie::Schema::StructureDumper  }
  let(:object) { klass.new }
  let(:id){ Cassandra::TimeUuid::Generator.new.now }
  let(:number){ '0.1.2' }
  let(:description){ 'some description' }
  let(:executor){ 'eprothro' }
  let(:executed_at){ Time.now - rand(10000) }
  let(:version){ Cassie::Schema::Version.new(number, description, id, executor, executed_at) }
  let(:versions){ [version] }
  before(:all) do
    Cassie::Schema::SelectVersionsQuery.include(Cassie::Testing::Fake::SessionMethods)
    Cassie::Schema::InsertVersionQuery.include(Cassie::Testing::Fake::SessionMethods)
  end

  describe "dump" do
    let(:keyspace_structure){ "keyspace structure CQL\n" }
    let(:schema_meta_structure){ "schema tracking structure CQL\n" }
    let(:versions_insert_cql){ "INSERT into cassie_schema.versions (props) VALUES (vals);" }
    let(:buffer){ StringIO.new }
    before(:each) do
      allow(object).to receive(:stream){ buffer }
      allow(object).to receive(:keyspace_structure){ keyspace_structure }
      allow(object).to receive(:schema_meta_structure){ schema_meta_structure }
      allow(object).to receive(:versions_insert_cql){ versions_insert_cql }
    end
    it "writes keyspace structure to stream" do
      object.dump
      expect(buffer.string).to start_with(keyspace_structure)
    end
    it "writes schema structure to stream" do
      object.dump
      expect(buffer.string).to match(/\n#{Regexp.quote(schema_meta_structure)}/)
    end
    it "writes versions_insert_cql to stream" do
      object.dump
      expect(buffer.string).to match(/\n#{Regexp.quote(versions_insert_cql)}/)
    end
    it "ends with newline" do
      object.dump
      expect(buffer.string).to end_with("\n")
    end
    it "closes io" do
      expect(buffer).to receive(:close)
      object.dump
    end
  end

  describe "stream" do
    it "is a file at configured path" do
    end
  end

  describe "versions" do
    let(:rows){ versions.map(&:to_h) }
    let(:versions_query) do
      q = Cassie::Schema::SelectVersionsQuery.new
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

    it "inserts into fully qualified versions table" do
      expect(object.versions_insert_cql).to match(/^insert into cassie_schema.versions/i)
    end
    it "inserts into 0th bucket" do
      expect(extract_cql_values(object.versions_insert_cql)['bucket']).to eq "0"
    end
    it "inserts for each element of versions" do
      expect(object.versions_insert_cql).to match(/\(bucket, id, number, description, executor, executed_at\) VALUES/i)
    end
    it "inserts id" do
      expect(extract_cql_values(object.versions_insert_cql)['id']).to eq version.id.to_s
    end
    it "inserts version number as string" do
      expect(extract_cql_values(object.versions_insert_cql)['number']).to eq "\'#{version.number}\'"
    end
    it "inserts description as string" do
      expect(extract_cql_values(object.versions_insert_cql)['description']).to eq "\'#{version.description}\'"
    end
    it "inserts executor as string" do
      expect(extract_cql_values(object.versions_insert_cql)['executor']).to eq "\'#{version.executor}\'"
    end
    xit "inserts executed_at as milliseconds since epoch UTC" do
      cql_ms_int = extract_cql_values(object.versions_insert_cql)['executed_at'].to_i
      expect(executed_at - Time.at(cql_ms_int / 1000.0)).to be < 0.001
    end

    context "when versions are empty" do
      let(:versions){ [] }
      it "is empty" do
        expect(object.versions_insert_cql).to eq("")
      end
    end
  end
end
