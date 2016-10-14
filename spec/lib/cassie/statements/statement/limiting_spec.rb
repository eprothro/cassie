RSpec.describe Cassie::Statements::Statement::Limiting do
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
  let(:alt_limit){ rand(2..(default_limit - 1)) }
  let(:default_limit) { Cassie::Statements.default_limit }

  before(:each){ @original = base_class.limit }
  after(:each){ base_class.limit = @original }

  describe "#statement" do
    context "when no limit has been set" do
      it "has default limit clause" do
        expect(object.statement.cql).to match(/LIMIT 500/)
      end
    end
    context "when class has limit" do
      let(:base_class) do
        Class.new(Cassie::FakeQuery) do
          select_from :users

          limit 1
        end
      end
      it "includes limit clause" do
        expect(object.statement.cql).to match(/LIMIT 1/)
      end
    end
  end

  describe "::Query#limit" do
    it "defaults to 500" do
      expect(base_class.limit).to eq(500)
    end

    context "when set" do
      it "overrides default" do
        base_class.limit = alt_limit
        expect(base_class.limit).to eq(alt_limit)
      end
    end
  end

  describe "subclass" do
    it "defaults to base default" do
      expect(subclass.limit).to eq(default_limit)
    end

    context "when base class is non-default" do
      it "inherits base class setting" do
        base_class.limit = alt_limit
        expect(subclass.limit).to eq(alt_limit)
      end
    end

    context "when set" do
      before(:each){ subclass.limit = alt_limit }

      it "overrides default" do
        expect(subclass.limit).to eq(alt_limit)
      end
      it "doesn't change base class" do
        expect(base_class.limit).to eq(default_limit)
      end
    end

    context "when subclass overrides limit" do
      let(:alt_limit){ 10 }
      let(:subclass) do
        Class.new(base_class) do
          def self.limit
            10
          end
        end
      end

      it "overrides base class setting" do
        expect(subclass.limit).to eq(alt_limit)
      end
      it "doesn't change base class" do
        expect(base_class.limit).to eq(default_limit)
      end
    end
  end

  describe "subclass object" do
    it "defaults to base_class value" do
      expect(object.limit).to eq(default_limit)
    end

    context "when set" do
      before(:each){ object.limit = alt_limit }

      it "overrides default" do
        expect(object.limit).to eq(alt_limit)
      end
      it "doesn't change subclass" do
        expect(subclass.limit).to eq(default_limit)
      end
      it "doesn't change base class" do
        expect(base_class.limit).to eq(default_limit)
      end
    end
  end

  context "when subclass overrides limit" do
    let(:alt_limit){ 10 }
    let(:subclass) do
      Class.new(base_class) do
        def self.limit
          10
        end
      end
    end

    it "defaults to subclass value" do
      expect(object.limit).to eq(alt_limit)
    end

    context "when object sets value" do
      let(:object_limit){ rand(1..(alt_limit - 1)) }
      before(:each){ object.limit = object_limit }

      it "overrides subclass default" do
        expect(object.limit).to eq(object_limit)
      end
    end
  end

  describe "#with_limit" do
    let!(:original_limit){ object.limit }
    let(:alt_limit){ original_limit + 1 }

    it "requires a block" do
      expect{object.with_limit(2)}.to raise_error(ArgumentError)
    end
    it "changes the object's limit during block execution" do
      object.with_limit(alt_limit) do
        expect(object.limit).to eq(alt_limit)
      end
    end
    it "changes the object's limit back after block execution" do
      object.with_limit(alt_limit) do
      end
      expect(object.limit).to eq(original_limit)
    end

    context "when limit is overriden" do
      let(:subclass) do
        Class.new(Cassie::FakeQuery) do
          select_from :test

          def limit
            700
          end
        end
      end

      it "changes the object's limit during block execution" do
        object.with_limit(object.limit + 1) do
          expect(object.limit).to eq(701)
        end
      end
      it "changes the object's limit back after block execution" do
        object.with_limit(object.limit + 1) do
        end
        expect(object.limit).to eq(700)
      end
    end

    context "when limit is set via setter" do
      before(:each){ object.limit = 800 }

      it "changes the object's limit during block execution" do
        object.with_limit(object.limit + 1) do
          expect(object.limit).to eq(801)
        end
      end
      it "changes the object's limit back after block execution" do
        object.with_limit(object.limit + 1) do
        end
        expect(object.limit).to eq(800)
      end
    end

    context "when a singleton method already exists" do
      before(:each) do
        def object.limit
          0
        end
      end
      it "raises" do
        expect{ object.with_limit(alt_limit){} }.to raise_error(NameError)
      end
    end

    context "when object is cloned during block execution" do
      it "clones with original limit" do
        cloned_object = nil
        object.with_limit(alt_limit) do
          cloned_object = object.clone
          expect(cloned_object.limit).to eq(original_limit)
        end
        expect(cloned_object.limit).to eq(original_limit)
      end
      it "original object still has temporary limit" do
        cloned_object = nil
        object.with_limit(alt_limit) do
          cloned_object = object.clone
          expect(object.limit).to eq(alt_limit)
        end
        expect(object.limit).to eq(original_limit)
      end
    end
  end
end
