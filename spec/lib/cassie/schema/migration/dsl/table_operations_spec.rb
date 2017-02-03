require 'support/versions'
Cassie::Schema::Migration.announcing_stream = StringIO.new

RSpec.describe Cassie::Schema::Migration::DSL::TableOperations do
  let(:klass){ Cassie::Schema::Migration }
  let(:object){ klass.new }

  describe "create_column" do
    let(:table){ 'table_name' }
    let(:column){ 'column_name' }

    it "executes create table column cql" do
      expect(object).to receive(:execute).with("CREATE TABLE table_name (column_name boolean, PRIMARY KEY((column_name)))")

      object.create_table table,
                          partition_keys: [column] do |t|
       t.boolean column
     end
    end
  end
end
