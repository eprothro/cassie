RSpec.describe Cassie::Statements::Statement::Pagination do
  let(:klass) do
    Class.new(Cassie::FakeQuery)
  end
  let(:object) { klass.new }
  let(:limit){ rand(2..500) }

  before(:each){ @original = klass.page_size }
  after(:each){ klass.page_size = @original }

  describe ".page_size" do
    it "aliases limit" do
      klass.limit = limit - 1
      expect{klass.limit = limit}.to change{klass.page_size}.to(limit)
    end
    context "with dsl limit setting" do
      let(:klass) do
        Class.new(Cassie::FakeQuery) do
          page_size 7
        end
      end
      it "aliases dsl limit setting" do
        expect(klass.limit).to eq(7)
      end
    end
  end

  describe ".page_size=" do
    it "aliases limit" do
      expect{klass.page_size = limit}.to change{klass.limit}.to(limit)
    end
  end

  describe "#page_size" do
    it "aliases limit" do
      expect{object.limit = limit}.to change{object.page_size}.to(limit)
    end
  end
  describe "#page_size=" do
    it "aliases limit" do
      expect{object.page_size = limit}.to change{object.limit}.to(limit)
    end
  end
end
