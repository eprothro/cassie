RSpec.describe Cassie::Statements::Statement::AllowFiltering do
  let(:base_class) do
    Class.new(Cassie::FakeQuery) do
      select_from :users
    end
  end
  let(:subclass) do
    Class.new(base_class) do
      select_from :users
    end
  end
  let(:object) { subclass.new }

  describe "#allow_filtering?" do
    context "when filtering has not been allowed" do
      it "filtring is not allowed" do
        expect(object.allow_filtering?).to be_falsy
      end
    end
    context "when filtering is set" do
      let(:base_class) do
        Class.new(Cassie::FakeQuery) do
          select_from :users

          allow_filtering
        end
      end
      it "is set as allowed" do
        expect(object.allow_filtering?).to be_truthy
      end
    end
  end

  describe "statement" do
    context "when filtering is allowed" do
      before(:each){ allow(object).to receive(:allow_filtering?){ true } }
      it "contains allow filtering" do
        expect(object.statement.cql).to match(/ ALLOW FILTERING/)
      end
    end

    context "when filtering is now allowed" do
      before(:each){ allow(object).to receive(:allow_filtering?){ false } }
      it "contains allow filtering" do
        expect(object.statement.cql).not_to match(/ ALLOW FILTERING/)
      end
    end

  end
end
