RSpec.describe Cassie::Queries::Statement::Preparation do
  let(:base_class){ Cassie::Query }
  let(:klass) do
    Class.new(base_class) do
      attr_accessor :add_constraint

      select :resources
      where :id, :eq, if: :add_constraint
    end
  end
  let(:object) { klass.new }

  before(:each) do
    @original = base_class.prepare
  end
  after(:each) do
    base_class.prepare = @original
    Cassie::Queries::Statement::Preparation.cache.clear
  end

  describe ".prepare" do
    it "defaults to true" do
      expect(klass.prepare).to eq(true)
    end
    it "inherits default value from parent" do
      base_class.prepare = false
      expect(klass.prepare).to eq(false)
    end
    it "is independent of it's parent's value" do
      expect{ base_class.prepare = !base_class.prepare }
      .to_not change{ klass.prepare }
    end
  end
  describe "#statement" do
    let(:prepared_statement){ double(bind: "some bound statement") }
    let(:result){ double(empty?: true) }
    let(:session){ double(execute: result, prepare: prepared_statement) }
    let(:object) do
      o = klass.new
      allow(o).to receive(:session){ session }
      o
    end
    let(:cache){ Cassie::Queries::Statement::Preparation.cache }

    it "prepares the statement once" do
      expect(session).to receive(:prepare){ prepared_statement }

      object.execute
    end
    it "doesn't prepare the statement a second time" do
      object.execute
      expect(session).to_not receive(:prepare)
      object.execute
    end

    context "when the statement is reused from the cache" do
      it "is gets param bindings" do
      end
    end

    context "when the statement changes" do
      it "prepares the new statement" do
        object.execute
        object.add_constraint = true
        object.execute

        expect(cache.instance_variable_get(:@data).size).to eq(2)
      end
    end
  end
end
