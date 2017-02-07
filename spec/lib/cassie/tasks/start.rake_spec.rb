require 'cassie/tasks'

RSpec.describe "cassie:start rake task" do
  let(:object){ Rake::Task["cassie:start"] }
  let(:buffer){ StringIO.new }
  let(:proc){ double(running?: true) }

  before(:each) do
    allow($stdout).to receive(:puts){|val| buffer.puts(val) }
    allow(Cassie::Support::ServerProcess).to receive(:new){ proc }
  end

  describe "#invoke" do
    it "creates server process" do
      expect(Cassie::Support::ServerProcess).to receive(:new)
      object.invoke
    end
    xit "prints success message" do
      pending "puts stubbing in class (can't stub stdout)"
      expect(buffer.string).to match(/Cassandra Running/)
      object.invoke
    end

    context "when server fails" do
      let(:proc){ double(running?: false, errors: ["foo"]) }

    end

  end
end