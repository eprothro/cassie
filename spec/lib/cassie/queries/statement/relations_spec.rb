RSpec.describe Cassie::Queries::Statement::Relations do
  # let(:base_class){ Cassie::FakeQuery }
  let(:klass) do
    Class.new do
      include Cassie::Queries::Statement::Relations
    end
  end
  let(:object){ klass.new }

  describe "#where" do
    it "allows custom defintion" do
      #where "username = ?", :username
    end
    it "supports eq dsl" do
      #where :username, :eq
    end

    context "with :in operation" do
      let(:klass) do
        Class.new(base_class) do
          select :users_by_phone
          where :phone, :in
        end
      end

      it "adds a relation" do


      end
    end
  end
end
