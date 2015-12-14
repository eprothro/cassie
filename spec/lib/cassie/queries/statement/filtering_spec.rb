RSpec.describe Cassie::Queries::Statement::Filtering do
  let(:klass) do
    Class.new(Cassie::Query) do
      where :field, :matcher
    end
  end
  let(:object) { klass.new }
  let(:filter_value){ :foo }

  describe "#where" do
    it "adds to class wheres" do
      expect(klass.wheres.first).to eq([:field, :matcher, :field])
    end
  end

  describe "field=" do
    it "sets filter value" do
      object.field = filter_value
      expect(object.field).to eq(filter_value)
    end
  end
end
