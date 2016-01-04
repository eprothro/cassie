RSpec.describe Cassie::Queries::Statement::Relations do
  let(:base_class){ Cassie::Query }
  let(:klass) do
    Class.new(base_class) do
      attr_accessor :foo

      delete :resources_by_tag
    end
  end
  let(:object) do
      o = klass.new
      allow(o).to receive(:execute)
      allow(o).to receive(:result){ double(empty?: true, rows: []) }
      o
  end
  let(:resource){ double }

  describe "#where" do
    it "allows custom defintion" do
      #where "username = ?", :username
    end
    it "allows dsl definition" do
      #where :username, :eq
    end
  end
end
