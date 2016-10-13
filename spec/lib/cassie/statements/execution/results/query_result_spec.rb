require 'support/resource'

RSpec.describe Cassie::Statements::Results::QueryResult do
  let(:klass){ Cassie::Statements::Results::QueryResult }
  let(:object){ klass.new(rows_obj, opts) }
  let(:opts){ {} }
  let(:rows_obj){ double(rows: rows_data) }
  let(:rows_data){ i=0; Array.new(rows){ i += 1 } }
  let(:rows){ 1 }

  describe "first" do
    it "returns first result" do
      expect(object.first).to eq(1)
    end
  end

  describe "first!" do
    it "returns first result" do
      expect(object.first!).to eq(1)
    end

    context "with no results" do
      let(:rows){ 0 }
      it "raises" do
        expect{object.first!}.to raise_error(Cassie::Statements::RecordNotFound)
      end
    end
  end
end
