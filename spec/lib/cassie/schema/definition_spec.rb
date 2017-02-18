RSpec.describe Cassie::Schema::Definition do
  let(:mod) do
    Module.new do
      extend Cassie::Schema::Definition
    end
  end

  describe "define" do
    it "executes DSL methods within block" do
      expect(Cassie::Schema::Definition::DSL).to receive(:create_schema).with("foo")

      mod.define{ create_schema("foo") }
    end
  end
end