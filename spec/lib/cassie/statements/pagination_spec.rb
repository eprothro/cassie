RSpec.describe Cassie::Statements::Statement::Pagination do
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
  let(:alt_page_size){ rand(2..(default_page_size - 1)) }
  let(:default_page_size) { Cassie::Statements.default_limit }

  before(:each){ @original = base_class.page_size }
  after(:each){ base_class.page_size = @original }

  describe "::Query#page_size" do
    context "when set" do
      it "overrides default" do
        base_class.page_size = alt_page_size
        expect(base_class.page_size).to eq(alt_page_size)
      end
    end
  end

  describe "subclass" do
    it "defaults to base default" do
      expect(subclass.page_size).to eq(default_page_size)
    end

    context "when base class is non-default" do
      it "inherits base class setting" do
        base_class.page_size = alt_page_size
        expect(subclass.page_size).to eq(alt_page_size)
      end
    end

    context "when set" do
      before(:each){ subclass.page_size = alt_page_size }

      it "overrides default" do
        expect(subclass.page_size).to eq(alt_page_size)
      end
      it "doesn't change base class" do
        expect(base_class.page_size).to eq(default_page_size)
      end
    end

    context "when subclass overrides pages size" do
      let(:alt_page_size){ 10 }
      let(:subclass) do
        Class.new(base_class) do
          def self.page_size
            10
          end
        end
      end

      it "overrides base class setting" do
        expect(subclass.page_size).to eq(alt_page_size)
      end
      it "doesn't change base class" do
        expect(base_class.page_size).to eq(default_page_size)
      end
    end
  end

  describe "subclass object" do
    it "defaults to base_class value" do
      expect(object.page_size).to eq(default_page_size)
    end

    context "when set" do
      before(:each){ object.page_size = alt_page_size }

      it "overrides default" do
        expect(object.page_size).to eq(alt_page_size)
      end
      it "doesn't change subclass" do
        expect(subclass.page_size).to eq(default_page_size)
      end
      it "doesn't change base class" do
        expect(base_class.page_size).to eq(default_page_size)
      end
    end
  end
end
