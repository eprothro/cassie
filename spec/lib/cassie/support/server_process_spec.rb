require "cassie/support/server_process"
require "support/process_status"

RSpec.describe Cassie::Support::ServerProcess do
  let(:klass){ Cassie::Support::ServerProcess }
  let(:object){ klass.new(pid) }
  let(:pid){ nil }
  let(:command){ double(run: true, succeed: true, output: "") }


  before(:each) do
    allow(Cassie::Support::SystemCommand).to receive(:new){ command }
  end

  context "when the server is running" do
    let(:pid){ sample_pid }
    let(:command){ double(run: true, succeed: true, output: sample_ps_string) }

    describe ".all" do
      it "includes process" do
        expect(klass.all.first).to be_a(Cassie::Support::ServerProcess)
        expect(klass.all.first.pid).to eq(pid)
      end
    end
  end
end