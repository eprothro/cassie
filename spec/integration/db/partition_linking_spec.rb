RSpec.describe "Cassie partition linking" do
  # bucketed_records_by_owner contains 5 partitions
  # for owner_id 1 with buckets 0 - 4
  #
  # | owner 1, bucket 0 | record  1 | ... | record 10 |
  # | owner 1, bucket 1 | record 11 | ... | record 20 |
  # ...
  # | owner 1, bucket 4 | record 41 | ... | record 50 |
  #
  # bucketed_records_desc_by_owner contains 5 partitions
  # for owner_id 1 with buckets 0 - 4
  #
  # | owner 1, bucket 0 | record 10 | ... | record  1 |
  # | owner 1, bucket 1 | record 20 | ... | record 11 |
  # ...
  # | owner 1, bucket 4 | record 50 | ... | record 41 |
  #
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
        cursor_by :id

        link_partitions :bucket, :descending, [0,4]
      end
    end
    before(:each) do
      object.bucket = bucket
      object.max_id = max_id
      object.since_id = since_id
    end
    let(:limit){ 10 }
    let(:bucket){ 4 }
    let(:max_id){ nil }
    let(:since_id){ nil }
    
    context "when spanning multiple buckets" do
      let(:max_id){ 45 }
      
      it "results come from multiple partitions" do
        expect(object.fetch.map(&:id)).to eq((36..45).to_a.reverse)
      end
      it "provies next max id from next partition" do
        expect(object.fetch.next_max_id).to eq(35)
      end
    end
    
    context "when using since id" do
      context "when since_id is in the last partition" do
        let(:max_id){ nil }
        let(:since_id){ 44 }
        let(:limit){ 5 }

        it "sets next max id after cursor" do
          expect(object.fetch.next_max_id).to eq(45)
        end
        it "fetches results from cursor" do
          expect(object.fetch.map(&:id)).to eq((46..50).to_a.reverse)
        end
      end
      
      context "when since_id is not in the last partition" do
        let(:bucket){ 2 }
        let(:max_id){ nil }
        let(:since_id){ 24 }
        let(:limit){ 5 }

        it "sets next max id in the last bucket" do
          expect(object.fetch.next_max_id).to eq(45)
        end
        it "fetches results from the last bucket" do
          expect(object.fetch.map(&:id)).to eq((46..50).to_a.reverse)
        end
        it "fetches straight from the last partition" do
        end
        
        context "when results span multiple partitions" do
          let(:limit){ 50 }
        end
      end
    end
  end
end
