RSpec.describe Cassie::Statements::Execution::PartitionLinking::SimplePolicy do
  let(:execution) do
    double
  end
  let(:klass){ Cassie::Statements::Execution::PartitionLinking::SimplePolicy }
  let(:object){ klass.new(execution, :partition, :ascending, [0,1]) }

  describe "#next_key" do
    let(:key){ rand(1000) }

    it "advances" do
      expect(object.next_key(key)).to eq(key + 1)
    end
  end

  describe "#previous_key" do
    let(:key){ rand(1000) }

    it "advances" do
      expect(object.previous_key(key)).to eq(key - 1)
    end
  end

  describe "#combine_rows" do
    let(:a){ [1,2,3] }
    let(:b){ [4,5] }

    it "advances" do
      expect(object.combine_rows(a, b)).to eq([1,2,3,4,5])
    end
  end
end