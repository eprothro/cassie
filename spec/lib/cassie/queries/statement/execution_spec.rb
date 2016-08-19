RSpec.describe Cassie::Queries::Statement::Execution do
  let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new(base_class) do
      select :test
    end
  end
  let(:object) do
    klass.new
  end

  describe "#execute" do
    it "passes the statment and execution_options to Cassandra" do
    end

    it "returns true" do
      expect(object.execute).to be_truthy
    end
  end

  describe "execution_options" do
    it "defaults to an empty hash" do
      expect(object.execution_options.keys).to be_empty
    end

    context "when consistency is defined" do
      let(:opt_value){ :three }
      before(:each) do
        object.consistency = opt_value
      end

      it "includes consistency" do
        expect(object.execution_options[:consistency]).to eq(opt_value)
      end
    end

    context "when consistency is not defined" do
      before(:each) do
        object.consistency = nil
      end

      it "does not include consistency" do
        expect(object.execution_options.keys).not_to include(:consistency)
      end
    end
  end
end
