RSpec.describe Cassie::Queries::Pagination::Cursors do
  let(:klass) do
    Class.new(Cassie::Query) do
      select :users
    end
  end
  let(:object) { klass.new }
  let(:statement){ "statement" }
  let(:max_value){ 10 }
  let(:since_value){ 1 }

  describe ".max_cursor" do
    let(:klass) do
      Class.new(Cassie::Query) do
        select :users
        max_cursor :field
      end
    end
    it "adds a since_field getter/setter" do
      expect do
        object.max_field = max_value
      end.to change{object.max_field}.to(max_value)
    end
    it "adds a relation for the field with a <= matcher" do
      expect(object.relations.keys).to include(have_attributes(identifier: :field, op_type: :lteq))
    end
  end

  describe ".since_cursor" do
    let(:klass) do
      Class.new(Cassie::Query) do
        select :users
        since_cursor :field
      end
    end
    it "adds a since_field getter/setter" do
      expect do
        object.since_field = max_value
      end.to change{object.since_field}.to(max_value)
    end
    it "adds a relation for the field with a > matcher" do
      expect(object.relations.keys).to include(have_attributes(identifier: :field, op_type: :gt))
    end
  end

  describe ".cursor_by" do
    it "calls max_cursor" do
      expect(klass).to receive(:max_cursor).with(:field)
      klass.cursor_by(:field)
    end
    it "calls since_cursor" do
      expect(klass).to receive(:since_cursor).with(:field)
      klass.cursor_by(:field)
    end
  end

  describe "#statement" do
    let(:klass) do
      Class.new(Cassie::Query) do
        select :users
        cursor_by :field
      end
    end

    context "when max_field present" do
      before(:each) do
        object.max_field = max_value
      end
      it "adds a binding marker for max_field" do
        expect(object.statement.cql).to match(/field <= ?/)
      end
    end

    context "when max_field not present" do
      it "doesn't add a binding marker for max_field" do
        expect(object.statement.cql).not_to match(/field <= ?/)
      end
    end

    context "when since_field present" do
      before(:each) do
        object.since_field = since_value
      end
      it "adds a binding marker for max_field" do
        expect(object.statement.cql).to match(/field > ?/)
      end
    end
    context "when since_field not present" do
      it "doesn't add a binding marker for since_field" do
        expect(object.statement.cql).not_to match(/field > ?/)
      end
    end
  end

  describe "#next_max_field" do
    let(:klass) do
      Class.new(Cassie::Query) do
        select :users
        cursor_by :id
        self.page_size = 1
      end
    end
    context "when query has executed" do
      before(:each) do
        allow(object.session).to receive(:execute){result}
        object.execute
      end
      let(:result){ CassandraFake::Result.new(object.statement, rows: rows) }
      let(:rows){ [] }

      context "when there is a next record" do
        let(:rows){ [{"id" => 1},{"id" => 2}] }

        it "returns field value of next record" do
          expect(object.next_max_id).to eq(2)
        end
      end

      context "when there is no next record" do
        let(:rows){ [{"id" => 1}] }

        it "returns nil" do
          expect(object.next_max_id).to be_nil
        end
      end
    end
  end
end
