RSpec.describe Cassie::Statements::Statement::Selection do
  let(:klass) do
    Class.new do
      include Cassie::Statements::Statement::Selection
    end
  end
  let(:object){ klass.new }
  let(:selector){ 'some_column' }
  let(:alias_name){ selector + "_alias" }

  describe "#select" do
    it "adds string selector" do
      expect{klass.select(selector)}.to change{klass.selectors}.to([selector])
    end
    it "adds symbol selector" do
      expect{klass.select(selector.to_sym)}.to change{klass.selectors}.to([selector])
    end
    it "has access to class level selection helpers" do
      subclass = Class.new(klass) do
        select writetime('some_column')
      end
      expect(subclass.selectors).to eq([klass.write_time(selector)])
    end

    context "with :as option" do
      it "adds alias" do
        klass.select(selector, as: alias_name)
        expect(klass.selectors).to eq(["#{selector} AS #{alias_name}"])
      end
      it "works with helpers" do
        klass.select klass.writetime('some_column'), as: :test

        expect(klass.selectors).to eq(["#{klass.write_time(selector)} AS test"])
      end
    end
  end

  describe "writetime" do
    it "uses writetime keyword" do
      expect(klass.writetime(selector)).to eq("WRITETIME(#{selector})")
    end
  end

  describe "ttl" do
    it "uses ttl keyword" do
      expect(klass.ttl(selector)).to eq("TTL(#{selector})")
    end
  end

  describe "count" do
    it "uses COUNT keyword" do
      expect(klass.count(selector)).to eq("COUNT(#{selector})")
    end
    it "defalts to COUNT(*)" do
      expect(klass.count()).to eq("COUNT(*)")
    end
  end

  describe "build_select_clause" do
    context "with multiple selections" do
      before(:each) do
        klass.select :foo
        klass.select 'bar'
      end
      it "joins with commas" do
        expect(object.send(:build_select_clause)).to eq("foo, bar")
      end
    end
  end
end
