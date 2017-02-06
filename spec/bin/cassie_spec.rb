RSpec.describe "cassie executable" do
  let(:args){ Array(command) + params }
  let(:params){ [] }
  let(:command){ nil }

  describe "#run" do
    before(:each) do
      stub_const("ARGV", args)
    end

    def run
      load File.join(Dir.pwd, "/bin/cassie")
    end

    context "when passed a command" do
      let(:command){ "some_command" }
      it "calls run command" do
        expect_any_instance_of(Cassie::Tasks::TaskRunner).to receive(:run_command)
        run
      end
    end

    context "when passed no command"  do
      it "calls documentation" do
        expect_any_instance_of(Cassie::Tasks::TaskRunner).to receive(:print_documentation)
        run
      end
    end
  end
end