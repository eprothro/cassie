require "support/process_status"

RSpec.describe Cassie::Support::SystemCommand do
  let(:klass){ Cassie::Support::SystemCommand }
  let(:object){ klass.new(command, args) }
  let(:command){ "ls" }
  let(:args){ [] }

  describe "run" do
    context "when there is output" do
      let(:command){ "echo" }
      let(:args){ [rand(10000).to_s] }

      it "has output" do
        object.run
        expect(object.output).to eq(args.first)
      end
    end
  end

  describe "which" do
    context "when binary exists" do
      let(:path) do
       # @todo add integration spec for this?
       cmd = klass.new('which', [command])
       cmd.succeed
       cmd.output
     end

      it "returns fully qualified path" do
        expect(object.which).to eq(path)
      end
    end
  end
end