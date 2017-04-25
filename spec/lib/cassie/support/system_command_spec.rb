require "support/process_status"

RSpec.describe Cassie::Support::SystemCommand do
  let(:klass){ Cassie::Support::SystemCommand }
  let(:object){ klass.new(binary, args) }
  let(:binary){ "ls" }
  let(:args){ [] }

  describe "initialize" do
    let(:binary){ "binary" }
    let(:args){ ["arg", "--switch", "val"] }

    context "with full command param" do
      let(:object){ klass.new("binary arg --switch val") }
      it "parses binary and args correctly" do
        expect(object.binary).to eq(binary)
        expect(object.args).to eq(args)
      end
    end
    context "with splatted args" do
      let(:object){ klass.new("binary", "arg", "--switch val") }
      it "parses binary and args correctly" do
        expect(object.binary).to eq(binary)
        expect(object.args).to eq(args)
      end
    end
    context "with array switch pair" do
      let(:object){ klass.new("binary", ["arg", "--switch val"]) }
      it "parses binary and args correctly" do
        expect(object.binary).to eq(binary)
        expect(object.args).to eq(args)
      end
    end
    context "with array args" do
      let(:object){ klass.new("binary", ["arg", "--switch", "val"]) }
      it "parses binary and args correctly" do
        expect(object.binary).to eq(binary)
        expect(object.args).to eq(args)
      end
    end
    context "with string args" do
      let(:object){ klass.new("binary", "arg --switch val") }
      it "parses binary and args correctly" do
        expect(object.binary).to eq(binary)
        expect(object.args).to eq(args)
      end
    end
    context "with array" do
      let(:object){ klass.new(["binary", "arg", "--switch", "val"]) }
      it "parses binary and args correctly" do
        expect(object.binary).to eq(binary)
        expect(object.args).to eq(args)
      end
    end
    context "with no args" do
      let(:object){ klass.new("binary") }
      it "parses binary and args correctly" do
      end
    end
  end

  describe "exist?" do
    context "when binary exist" do
      it "returns true" do
        expect(object.exist?).to eq(true)
      end
    end

    context "when binary does not exist at path" do
      let(:binary){ "some_binary_that_certainly_does_not_exist" }

      it "returns false" do
        expect(object.exist?).to eq(false)
      end
    end
  end

  describe "which" do
    context "when binary exists" do
      let(:path) do
       "/bin"
     end

      it "returns fully qualified path" do
        expect(object.which).to start_with "/"
        expect(object.which).to end_with "ls"
      end
    end

    context "when binary does not exist at path" do
      let(:binary){ "some_binary_that_certainly_does_not_exist" }

      it "returns nil" do
        expect(object.which).to eq(nil)
      end
    end
  end
end