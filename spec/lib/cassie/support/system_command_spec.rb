require "support/process_status"

RSpec.describe Cassie::Support::SystemCommand do
  let(:klass){ Cassie::Support::SystemCommand }
  let(:object){ klass.new(command, args) }
  let(:command){ "ls" }
  let(:args){ [] }


  describe "exist?" do
    context "when binary exist" do
      it "returns true" do
        expect(object.exist?).to eq(true)
      end
    end

    context "when binary does not exist at path" do
      let(:command){ "some_command_that_certainly_does_not_exist" }

      it "returns false" do
        expect(object.exist?).to eq(false)
      end
    end
  end

  describe "which" do
    context "when binary exists" do
      let(:path) do
       # @todo add integration spec for this?
       # cmd = klass.new('which', [command]).succeed
       # cmd.output
       "/bin"
     end

      it "returns fully qualified path" do
        expect(object.which).to start_with "/"
        expect(object.which).to end_with "ls"
      end
    end

    context "when binary does not exist at path" do
      let(:command){ "some_command_that_certainly_does_not_exist" }

      it "returns nil" do
        expect(object.which).to eq(nil)
      end
    end
  end
end