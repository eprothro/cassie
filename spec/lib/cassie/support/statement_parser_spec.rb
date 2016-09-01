require 'support/cql_parsing'

RSpec.describe Cassie::Support::StatementParser do
  let(:klass) do
    Cassie::Support::StatementParser
  end
  let(:object) { klass.new(statement) }
  let(:statement){ Cassandra::Statements::Simple.new(cql, params) }
  let(:cql){ "SELECT * from table WHERE attr = ?" }
  let(:value) { string_val }
  let(:string_val){ 'test' }
  let(:timestamp_val){ Time.now }
  let(:uuid_val){ Cassandra::Uuid::Generator.new.uuid }
  let(:int_val){ rand(10000) }
  let(:params) { [value] }

  describe "#to_cql" do

    context "with string" do

      it "inserts value as quoted value" do
        expect(extract_cql_values(object.to_cql)['attr']).to eq "\'#{value}\'"
      end
    end

    context "with uuid" do
      let(:value) { uuid_val }

      it "inserts value as unquoted value" do
        expect(extract_cql_values(object.to_cql)['attr']).to eq value.to_s
      end
    end

    context "with timestamp" do
      let(:value) { timestamp_val }

      it "inserts value as quoted value" do
        expect(extract_cql_values(object.to_cql)['attr']).to eq "\'#{value}\'"
      end
      it "inserts value as iso_8601" do
        # https://docs.datastax.com/en/cql/3.0/cql/cql_reference/timestamp_type_r.html
        # 2011-02-03T04:05+0000
        expect(extract_cql_values(object.to_cql)['attr']).to eq "\'#{value}\'"
      end
      xit "preserves fractional seconds" do
        #TODO: use integer?
      end

    end

    context "with int" do
      let(:value) { int_val }

      it "inserts value as unquoted value" do
        expect(extract_cql_values(object.to_cql)['attr']).to eq value.to_s
      end
    end
  end
end
