RSpec.describe Cassie::Statements::Statement::Conditions do
  let(:base_class){ Cassie::FakeModification }
  let(:klass) { base_class }
  let(:object) { klass.new }

  def condition_str
    object.send(:build_condition_and_params).first
  end
  def condition_bindings
    object.send(:build_condition_and_params).last
  end

  describe "build_condition_and_params" do
    context "when no conditions set up" do
      it "builds nothing" do
        expect(condition_str).to be_blank
        expect(condition_bindings).to be_empty
      end
    end

    context "when if_not_exists configured" do
      let(:klass) do
        Class.new(base_class) do
          if_not_exists
        end
      end

      it "returns IF NOT EXISTS string" do
        expect(condition_str).to eq("IF NOT EXISTS")
      end
      it "returns no binding" do
        expect(condition_bindings).to be_empty
      end
    end

    context "when if_exists configured" do
      let(:klass) do
        Class.new(base_class) do
          if_exists
        end
      end

      it "returns IF EXISTS string" do
        expect(condition_str).to eq("IF EXISTS")
      end
    end
  end
end
