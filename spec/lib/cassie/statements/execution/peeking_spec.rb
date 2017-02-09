RSpec.describe Cassie::Statements::Execution::Peeking do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
      include Cassie::Statements::Execution::Peeking

      select_from :test
      limit 1
    end
  end
  let(:object)do
    o = klass.new
    o.session.rows = row_data
    o
  end
  let(:row_data){ i=0; Array.new(rows){ {'id' => i+=1} } }
  let(:rows){ 2 }

  # @todo make these tests more abstract. Test that peeking makes peeking result
  # the result class, makes result option avialable and results in execution of
  # +1 rows. Other tests to should ensure those things are consumed properly.
  describe "#execute" do
    it "returns peeking result" do
      object.execute
      expect(object.result).to be_a(Cassie::Statements::Results::PeekingResult)
    end
    it "gives correct count of results" do
      object.execute
      expect(object.result.count).to eq(1)
    end
    it "gives correctly limited results" do
      object.execute
      expect(object.result.to_a.length).to eq(1)
    end
    it "gives correctly limited rows" do
      object.execute
      expect(object.result.rows.count).to eq(1)
      expect(object.result.rows.first['id']).to eq(1)
    end
    it "sets limit of peeking result" do
      object.execute
      expect(object.result.limit).to eq(1)
    end
    it "makes peeked result available" do
      object.execute
      expect(object.result.peeked_result.id).to eq(2)
    end
    it "makes peeked row available" do
      object.execute
      expect(object.result.peeked_row['id']).to eq(2)
    end
  end
end
