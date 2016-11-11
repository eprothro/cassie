RSpec.describe "Cassie curosred pagination" do
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
      select_from :bucketed_records_desc_by_owner

      where :owner_id, :eq
      where :bucket, :eq
      cursor_by :id

      def bucket
        4
      end
    end
  end
  let(:object) do
    o = klass.new
    o.limit = limit
    o.owner_id = 1
    o.max_id = max_id
    o.since_id = since_id
    o
  end
  let(:limit){ 5 }
  let(:max_id){ nil }
  let(:since_id){ nil }

  context "when no cursors are given" do
    it "sets next max id after cursor" do
      expect(object.fetch.next_max_id).to eq(45)
    end
    it "fetches results from cursor" do
      expect(object.fetch.map(&:id)).to eq((46..50).to_a.reverse)
    end
    it "fetches first result" do
      pending "fixing issue #20"
      expect(object.fetch_first.id).to eq(50)
    end
  end

  context "when cursoring by max_id" do
    let(:max_id){ 46 }

    it "sets next max id after cursor" do
      expect(object.fetch.next_max_id).to eq(41)
    end
    it "fetches results from cursor" do
      expect(object.fetch.map(&:id)).to eq((42..46).to_a.reverse)
    end
  end

  context "when cursoring by since_id" do
    let(:since_id){ 44 }

    it "sets next max id after cursor" do
      expect(object.fetch.next_max_id).to eq(45)
    end
    it "fetches results from cursor" do
      expect(object.fetch.map(&:id)).to eq((46..50).to_a.reverse)
    end
    context "when results meet cursor" do
      let(:since_id){ 46 }

      it "sets next max id after cursor" do
        expect(object.fetch.next_max_id).to eq(nil)
      end
      it "fetches results from cursor" do
        expect(object.fetch.map(&:id)).to eq((47..50).to_a.reverse)
      end
    end
  end

  context "when cursoring by since_id and max_id" do
    let(:since_id){ 41 }
    let(:max_id){ 49 }

    it "sets next max id after cursor" do
      expect(object.fetch.next_max_id).to eq(44)
    end
    it "fetches results from cursor" do
      expect(object.fetch.map(&:id)).to eq((45..49).to_a.reverse)
    end
  end
end
