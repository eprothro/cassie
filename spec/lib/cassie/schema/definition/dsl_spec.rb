RSpec.describe Cassie::Schema::Definition::DSL do
  let(:klass) { Cassie::Schema::Definition::DSL }
  let(:cql){ "valid cql;" }
  let(:session){ double(execute: nil) }

  describe "create_schema" do
    before(:each) do
      allow(Cassie).to receive(:session).with(nil){ session }
    end

    it "executes on global session" do
      expect(Cassie).to receive(:session).with(nil){ session }
      expect(session).to receive(:execute).with(cql)

      klass.create_schema(cql)
    end

    context "with instance eval'd interpolated cql" do
      def klass_eval
        klass.instance_eval do
          create_schema("cql with #{default_keyspace}")
        end
      end

      it "receives default kesypace interpolation" do
        allow(klass).to receive(:default_keyspace){ "some_keyspace" }
        expect(session).to receive(:execute) do | statement |
          expect(statement).to include("some_keyspace")
        end

        klass_eval
      end
    end

    context "with multiple cql statements" do
      let(:cql){ " valid cql; \n valid cql2; \n\n " }

      it "executes multiple statements" do
        statements = []
        allow(session).to receive(:execute) do |statement|
          statements << statement
        end

        klass.create_schema(cql)
        expect(statements).to eq(["valid cql;", "valid cql2;"])
      end
    end
  end

  describe "record_version"  do
    let(:number) { "1.0.1" }
    let(:description) { "some description" }
    let(:uuid) { Cassandra::TimeUuid::Generator.new.now }
    let(:uuid_str) { uuid.to_s }
    let(:executor) { "user" }
    let(:date) { Time.now }
    let(:date_str) { date.utc.iso8601(6) }
    let(:version){ Cassie::Schema::Version.new(number, description, uuid, executor, date) }

    def eval
      args = [number, description, uuid_str, executor, date_str]
      klass.instance_eval do
        record_version *args
      end
    end
    before(:each) do
      allow(Cassie::Schema).to receive(:initialize_versioning)
      allow(Cassie::Schema).to receive(:record_version)
    end
    it "calls record version" do
      allow(Cassie::Schema).to receive(:record_version) do |v|
        expect(v).to eq(version)
      end
      eval
    end

    it "makes uuid arg a valid uuid" do
      allow(Cassie::Schema).to receive(:record_version) do |v|
        expect(v.id).to be_a(Cassandra::TimeUuid)
        expect(v.id).to eq(uuid)
      end

      eval
    end

    it "makes date string a valid date" do
      allow(Cassie::Schema).to receive(:record_version) do |v|
        expect((v.executed_at.to_time - date).abs).to be < (0.001)
      end

      eval
    end

    it "makes executor available" do
      allow(Cassie::Schema).to receive(:record_version) do |v|
        expect(v.executor).to eq(executor)
      end

      eval
    end

    it "makes description available" do
      allow(Cassie::Schema).to receive(:record_version) do |v|
        expect(v.description).to eq(description)
      end

      eval
    end

    context "when executed_at is nil" do
      let(:date_str) { "" }
      it "makes executed_at nil" do
        allow(Cassie::Schema).to receive(:record_version) do |v|
          expect(v.executed_at).to eq(nil)
        end

        eval
      end
    end
  end
end