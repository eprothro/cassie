require 'cassie/tasks'

RSpec.describe "cassie:start rake task" do
  let(:object){ Rake::Task["cassie:start"] }
  let(:buffer){ StringIO.new }
  let(:process){ double(running?: true) }

  describe "#invoke" do
    before(:each) do
      allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
      allow(Cassie::Support::ServerProcess).to receive(:new){ process }
    end
    after(:each) { object.reenable }

    it "creates server process" do
      RSpec::Mocks.space.proxy_for(Cassie::Support::ServerProcess).reset
      expect(Cassie::Support::ServerProcess).to receive(:new){ process }
      object.invoke
    end
    it "prints success message" do
      object.invoke
      expect(buffer.string).to match(/Cassandra Running/)
    end

    context "when server fails" do
      let(:process){ double(running?: false, errors: ["foo"]) }

      it "prints failure message" do
        object.invoke
        expect(buffer.string).to match(/Cassandra Failed/)
      end
    end
  end
end