require 'support/resource'

RSpec.describe Cassie::Queries::Statement::Mapping do
  let(:base_class){ Cassie::Query }
  let(:klass) do
    Class.new(base_class) do
      insert :users_by_username
      set :id

      map_from :user
    end
  end
  let(:object) do
      o = klass.new
      allow(o).to receive(:execute)
      allow(o).to receive(:execution_successful?){ succeed? }
      o
  end
  let(:succeed?){ true }
  let(:user){ Resource.new(id: rand(10000)) }

  describe "#insert" do
    it "assigns the resource" do
      expect(object.insert(user))
      expect(object.user).to eq(user)
    end
    it "returns the resource" do
      expect(object.insert(user)).to eq(user)
    end
    context "when execution fails" do
      let(:succeed?){ false }
      it "returns false" do
        expect(object.insert(user)).to eq(false)
      end
    end
    context "when no resource is passed" do
      it "returns true" do
        expect(object.insert).to eq(true)
      end
    end
  end

  describe "field getter" do
    it "returns resource value" do
      object.user = user
      expect(object.id).to eq(user.id)
    end
    context "when accessor overwritten" do
      let(:klass) do
        Class.new(base_class) do
          insert :users_by_username
          set :id

          map_from :user

          def id
            "overrwrite"
          end
        end
      end
      it "returns resource value" do
        object.user = user
        expect(object.id).to eq("overrwrite")
      end
    end
  end
end
