RSpec.describe "Cassie partition linking" do
  let(:klass) do
    Class.new(Cassie::Query) do
      select_from :bucketed_records_by_owner

      where :owner_id, :eq
      where :bucket, :eq

      link_partitions :bucket, :ascending, [0,4]

      def bucket
        0
      end
    end
  end
  let(:object) do
    o = klass.new
    o.limit = limit
    o.owner_id = 1
    o
  end
  let(:limit){ 5 }

  context "when spanning multiple buckets" do
    let(:limit){ 30 }

    it "combines multiple results" do
      expect(object.fetch.map(&:id)).to eq((1..30).to_a)
    end
    it "has next id" do
      expect(object.fetch.peeked_result.id).to eq(31)
    end
  end

  context "when cursoring" do
    let(:klass) do
      Class.new(Cassie::Query) do
        select_from :bucketed_records_desc_by_owner

        where :owner_id, :eq
        where :bucket, :eq
        max_cursor :id

        link_partitions :bucket, :descending, [0,4]
      end
    end
    before(:each) do
      object.limit = 10
      object.bucket = 4
      object.max_id = 45
    end

    it "combines multiple results" do
      expect(object.fetch.map(&:id)).to eq((36..45).to_a.reverse.to_a)
    end
    it "has next max id" do
      expect(object.fetch.next_max_id).to eq(35)
    end
  end
end
