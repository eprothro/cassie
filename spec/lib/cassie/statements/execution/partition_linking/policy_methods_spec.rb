RSpec.describe Cassie::Statements::Execution::PartitionLinking::PolicyMethods do
  let(:execution_class) do
    Class.new(Cassie::FakeQuery) do
      include Cassie::Statements::Execution::Peeking
      select_from :test
      where :partition, :eq
      limit 2
    end
  end
  let(:execution) do
    ex = execution_class.new
    ex.partition = partition
    ex.session.rows = row_data
    ex
  end
  let(:partition){ 0 }
  let(:row_data){ i=0; Array.new(rows){ {id: i+=1} } }
  let(:rows){ 3 }
  let(:executed) do
    execution.execute
    execution
  end
  let(:klass){ Cassie::Statements::Execution::PartitionLinking::SimplePolicy }
  let(:object){ klass.new(executed, :partition, :ascending, [0,1]) }

  describe "#end_of_partition?" do
    it "is false" do
      expect(object.end_of_partition?).to be false
    end
    context "when there is no next result" do
      let(:rows){ 2 }
      it "is true" do
        expect(object.end_of_partition?).to be true
      end
    end
  end

  describe "#partition_available?" do
    let(:partition){ 0 }
    it "is true" do
      expect(object.partition_available?).to be true
    end

    context "when on last partition" do
      let(:partition){ 1 }
      it "is false" do
        expect(object.partition_available?).to be false
      end
    end
    context "when past last partition" do
      let(:partition){ 2 }
      it "is false" do
        expect(object.partition_available?).to be false
      end
    end
    context "when prior to first partition" do
      let(:partition){ -1 }
      it "is false" do
        expect(object.partition_available?).to be false
      end
    end
  end

  describe "#prepare_execution" do
    let(:rows){ 1 }
    it "has advanced partition" do
      allow(object).to receive(:next_key){ 2 }
      exec = object.prepare_execution
      expect(exec.partition).to eq 2
    end
    it "is limited to remaining results" do
      exec = object.prepare_execution
      expect(exec.limit).to eq 1
    end
  end

  describe "#link" do
    let(:rows){ 2 }
    before(:each) do
      executed.session.rows = [{id: 3}]
    end
    it "returns combined rows" do
      allow(object).to receive(:combine_results){ :foo }
      expect(object.link).to eq(:foo)
    end
    it "returns peeked row" do
      expect(object.link.peeked_row[:id]).to eq(3)
    end
    it "returns peeked result" do
      expect(object.link.peeked_result.id).to eq(3)
    end
    it "executes twice" do
      object.link
      expect(executed.session.query_count).to eq(2)
    end

    context "when no linking necessarry" do
      let(:rows){ 3 }

      it "executes once" do
        object.link
        expect(executed.session.query_count).to eq(1)
      end
    end
  end

  describe "last" do
    it "pulls value from last range value" do
      expect(object.send(:last_key)).to eq(1)
    end
    context "when defined dynamically" do
      let(:execution_class) do
        Class.new(Cassie::FakeQuery) do
          include Cassie::Statements::Execution::Peeking
          select_from :test
          where :partition, :eq
          limit 2

          def foo
            100
          end
        end
      end
      let(:object){ klass.new(executed, :partition, :ascending, [0, :foo]) }

      it "pulls value from reader" do
        expect(object.send(:last_key)).to eq(100)
      end
    end
  end
end