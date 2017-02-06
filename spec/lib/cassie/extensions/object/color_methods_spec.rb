require 'cassie/extensions/object/color_methods'

RSpec.describe Cassie::Extensions::Object::ColorMethods do

  describe "#red" do
    it "wraps string in red" do
      expect(red("string")).to eq("\e[1;31mstring\e[0m")
    end
  end

  describe "#white" do
    it "wraps string in red" do
      expect(white("string")).to eq("\e[1;37mstring\e[0m")
    end
  end

  describe "#green" do
    it "wraps string in red" do
      expect(green("string")).to eq("\e[1;32mstring\e[0m")
    end
  end
end