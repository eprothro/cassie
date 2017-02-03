require 'support/versions'

RSpec.describe Cassie::Schema::Migration::DSL::ColumnOperations do
  let(:klass){ Cassie::Schema::Migration }
  let(:object){ klass.new }

  describe "add_column" do
    let(:table){ 'table_name' }
    let(:column){ 'column_name' }
    let(:type){ :text }

    it "executes add column cql" do
      expect(object).to receive(:execute).with("ALTER TABLE table_name ADD column_name text")
      object.add_column table, column, type
    end
  end
end
