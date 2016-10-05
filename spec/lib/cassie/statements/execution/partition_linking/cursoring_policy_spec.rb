RSpec.describe Cassie::Statements::Execution::PartitionLinking::CursoringPolicy do
  let(:execution_klass) do
    Class.new(Cassie::FakeQuery) do
      select_from :users
      where :bucket, :eq
      cursor_by :field
      limit 2

      def bucket
        0
      end
    end
  end
  let(:executed) do
    ex = execution_klass.new
    ex.max_field = 123
    ex.execute
    ex
  end
  let(:klass){ Cassie::Statements::Execution::PartitionLinking::CursoringPolicy }
  let(:object){ klass.new(executed, :bucket, :ascending, [0,1]) }

  describe "query" do
    it "has a Cursoring Policy" do
      expect(execution_klass.partition_linker).to eq(klass)
    end
  end

  describe "#prepare_execution" do
    it "sets max_id to nil" do
      pending "support for since_id cursoring across buckets"
      object.prepare_execution
      expect(object.execution.max_field).to eq(nil)
    end
  end

  describe "next_max_cursor" do
    let(:executed) do
      ex = execution_klass.new
      ex.max_field = 123
      ex.session.rows = row_data
      ex.execute
      ex
    end
    let(:row_data){ i=0; Array.new(rows){ {field: i+=1} } }
    let(:rows){ 2 }

    before(:each) do
      executed.session.rows = [{'field' => 3}]
    end

    it "is the id from the next bucket" do
      expect(object.link.next_max_cursor).to eq(3)
    end
  end
end