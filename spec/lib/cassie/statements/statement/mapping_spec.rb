require 'support/resource'

RSpec.describe Cassie::Statements::Statement::Mapping do
  let(:base_class){ Cassie::FakeModification }
  let(:klass) do
    Class.new(base_class) do
      insert_into :users_by_username
      set :id

      map_from :user
    end
  end
  let(:object) { klass.new }
  let(:succeed?){ true }
  let(:user){ Resource.new(id: rand(10000)) }

  describe "field setter" do
    it "assigns resource value" do
      expect{ object.user = user }.to change{object.user}.to(user)
    end
    context "when set via initializer" do
      let(:object) { klass.new(user: user) }
      it "sets values" do
        expect(object.user).to eq(user)
      end
    end
  end

  describe "field getter" do
    before(:each){ object.user = user }
    it "returns resource value" do
      expect(object.id).to eq(user.id)
    end
    context "when accessor overridden" do
      let(:klass) do
        Class.new(base_class) do
          insert_into :users_by_username
          set :id

          map_from :user

          def id
            "override"
          end
        end
      end
      it "returns overridden value" do
        expect(object.id).to eq("override")
      end
    end
  end
end
