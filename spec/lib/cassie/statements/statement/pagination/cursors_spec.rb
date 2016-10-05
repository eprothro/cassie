RSpec.describe Cassie::Statements::Statement::Pagination::Cursors do
  let(:klass) do
    Class.new(Cassie::FakeQuery) do
      select_from :users
    end
  end
  let(:object) { klass.new }
  let(:statement){ "statement" }
  let(:max_value){ 10 }
  let(:since_value){ 1 }

  describe ".max_cursor" do
    let(:klass) do
      Class.new(Cassie::FakeQuery) do
        select_from :users
        max_cursor :field
      end
    end
    it "adds a since_field getter/setter" do
      expect do
        object.max_field = max_value
      end.to change{object.max_field}.to(max_value)
    end
    it "adds a relation for the field with a <= matcher" do
      expect(object.relations_args).to include([:field, :lteq, :max_field, if: :max_cursor_enabled?])
    end
  end

  describe ".since_cursor" do
    let(:klass) do
      Class.new(Cassie::FakeQuery) do
        select_from :users
        since_cursor :field
      end
    end
    it "adds a since_field getter/setter" do
      expect do
        object.since_field = max_value
      end.to change{object.since_field}.to(max_value)
    end
    it "adds a relation for the field with a > matcher" do
      expect(object.relations_args).to include([:field, :gt, :since_field, if: :since_cursor_enabled?])
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
      Class.new(Cassie::FakeQuery) do
        select_from :users
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
end
