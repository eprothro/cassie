RSpec.describe Cassie::Queries::Pagination::Pages do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
      select :users
    end
  end

  let(:object)    { klass.new }
  let(:statement) { "statement" }
  let(:next_page) { 10 }

  describe ".next_page" do
    let(:klass) do
      Class.new(Cassie::FakeQuery) do
        select :users
        next_page :field
      end
    end

    it "adds a next_page_field getter/setter" do
      expect do
        object.next_page_field = next_page
      end.to change{ object.next_page_field }.to(next_page)
    end

    it "adds a relation for the field with a > matcher" do
      expect(object.relations.keys).to include(have_attributes(identifier: :field, op_type: :gt))
    end
  end

  describe ".page_by" do
    it "calls next_page" do
      expect(klass).to receive(:next_page).with(:field)
      klass.page_by(:field)
    end
  end

  describe "#statement" do
    let(:klass) do
      Class.new(Cassie::FakeQuery) do
        select :users
        page_by :field
      end
    end

    context "when next_page_field present" do
      before { object.next_page_field = next_page }

      it "adds a binding marker for next_page_field" do
        expect(object.statement.cql).to match(/field > ?/)
      end

      it "adds ordering clause to query" do
        expect(object.statement.cql).to match(/ORDER BY field ASC/)
      end
    end

    context "when next_page_field not present" do
      it "doesn't add a binding marker for next_page_field" do
        expect(object.statement.cql).not_to match(/field <= ?/)
      end

      it "doesn't add ordering clause to query" do
        expect(object.statement.cql).not_to match(/ORDER BY field ASC/)
      end
    end
  end
end
