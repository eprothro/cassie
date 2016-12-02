RSpec.describe Cassie::Schema::Migration::Loader do
  let(:klass){ Cassie::Schema::Migration::Loader }
  let(:object){ klass.new(filename) }
  let(:filename){ "0000_0001.rb" }


  describe "class_name" do
    it "always outputs 4 parts" do
      expect(object.class_name).to eq("Migration_0_1_0_0")
    end
  end

  describe "version" do
    context "with description in file name" do
      let(:filename){ "0000_0001_description_test.rb" }

      it "has description" do
        expect(object.version.description).to eq("description_test")
      end

      it "has version" do
        expect(object.version.number).to eq("0.1.0.0")
      end
    end
  end
end

