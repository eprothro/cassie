RSpec.describe "Cassie relations" do
  let(:object) { klass.new }

  context "with a `where` constraint" do
    let(:klass) do
      Class.new(Cassie::Query) do
        select_from :records

        where :id, :eq
      end
    end

    it "constrains result" do
      object.id = 1

      expect(object.fetch.map(&:id)).to eq([1])
    end
  end

  context "with a disabled `where` constraint" do
    let(:klass) do
      Class.new(Cassie::Query) do
        select_from :records

        where :id, :eq, if: false
      end
    end

    it "does not constrain result" do
      expect(object.fetch.length).to be > 1
    end
  end
end
