RSpec.describe Cassie::Queries::Pagination::Cursors do
  let(:klass) do
    Class.new(Cassie::Query) do
      cql "statement"
    end
  end
  let(:object) { klass.new }
  let(:statement){ "statement" }

  describe "#max_cursor" do
    let(:klass) do
      Class.new(Cassie::Query) do
        max_cursor :field

      end
    end
    it "adds a next_max_field method" do
    end
    it "adds a where for the field with a <= matcher" do
    end

    describe "initiailize" do
      it "sets max_field"
    end
  end

  describe "#since_cursor" do
    let(:klass) do
      Class.new(Cassie::Query) do
        since_cursor :field

      end
    end
    it "adds a since_field getter" do
    end
    it "adds a since_field setter" do
    end
    it "adds a relation for the field with a > matcher" do
    end

    describe "initiailize" do
      it "sets since_field"
    end
  end

  describe "next_max_field" do
    context "when there is a next record" do
      it "returns field value of next record" do
        query.max_id = nil
        query.fetch
      end
    end

    context "when there is no next record" do
      it "returns nil" do
      end
    end
  end

  context "when field value is present for query" do
    it "adds a binding marker to the statement" do
    end
    it "adds a binding value" do
    end
  end

  context "when field value is not present for query" do
    it "doesn't add a binding marker to the statement" do
    end
    it "doesn't add a binding value" do
    end
  end
end
