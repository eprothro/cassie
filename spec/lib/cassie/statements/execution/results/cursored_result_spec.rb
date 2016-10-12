require 'support/resource'

RSpec.describe Cassie::Statements::Results::CursoredResult do
  let(:klass){ Cassie::Statements::Results::CursoredResult }
  let(:object) { klass.new(result, opts) }
  let(:result){ Cassie::Testing::Fake::Result.new('some CQL', rows: row_data) }
  let(:row_data){ i=0; Array.new(rows){ {'id' => i+=1} } }
  let(:rows){ 3 }
  let(:opts){ {max_cursor_key: 'id', limit: page_size} }
  let(:page_size){ rows - 1 }

  describe "next_max_id" do
    it "is peeked id" do
      expect(object.next_max_id).to eq(3)
    end
  end

  describe "next_max_cursor" do
    it "is peeked id" do
      expect(object.next_max_cursor).to eq(3)
    end
  end
end
