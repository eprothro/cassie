RSpec.describe Cassie::Statements::Execution::PartitionLinking do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
      select_from :test
      where :bucket, :eq

      link_partitions :bucket, :ascending, [0,1]
    end
  end
  let(:object) { klass.new }

  describe ".link_partitions" do
    it "sets the execution" do
      expect(object.build_partition_linker.peeking_execution).to eq(object)
    end
    it "sets the identifier" do
      expect(object.build_partition_linker.identifier).to eq(:bucket)
    end
    it "sets the direction" do
      expect(object.build_partition_linker.direction).to eq(:ascending)
    end
    it "sets the range" do
      expect(object.build_partition_linker.range).to eq([0,1])
    end
  end

  describe "execute" do
    let(:succeed?) { true }
    let(:object) do
      o = klass.new
      allow(o).to receive(:result){ double(success?: succeed?, :deserializer= => nil) }
      o
    end

    it "calls an instance of the policy" do
      expect_any_instance_of(klass.partition_linker).to receive(:link){ double(success?: true) }
      object.execute
    end

    context "when no linker defined" do
      let(:klass) do
        Class.new(Cassie::FakeQuery) do
          select_from :test
          where :bucket, :eq
        end
      end

      it "doesn't create the policy" do
        expect_any_instance_of(klass.partition_linker).not_to receive(:initialize)
        object.execute
      end
    end

    context "when unsuccessful" do
      let(:succeed?) { false }
      it "doesn't call the policy" do
        expect_any_instance_of(klass.partition_linker).not_to receive(:link)
        object.execute
      end
    end
  end

  describe "build_partition_linker" do
    it "sets up a SimplePolicy" do
      expect(object.build_partition_linker).to be_a(Cassie::Statements::Execution::PartitionLinking::SimplePolicy)
    end

    context "with a custom policy" do
      let(:custom_linker) do
        Class.new(Cassie::Statements::Execution::PartitionLinking::SimplePolicy)
      end
      before(:each){ klass.partition_linker = custom_linker }

      it "sets up a custom policy" do
        expect(object.build_partition_linker).to be_a(custom_linker)
      end
    end
  end
end


