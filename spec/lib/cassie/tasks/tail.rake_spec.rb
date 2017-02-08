require 'cassie/tasks'

RSpec.describe "cassie:tail rake task" do
  let(:object){ Rake::Task["cassie:tail"] }
  let(:options){ [] }
  let(:buffer){ StringIO.new }
  let(:log_path){ "some path" }

  before(:each) do
    allow(Cassie::Support::ServerProcess).to receive(:log_path){ log_path }
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:options){ options }
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
  end
  after(:each){ object.reenable }

  describe "#invoke" do
    it "calls tail -f" do
      expect(Cassie::Support::SystemCommand).to receive(:new){double(run: true)} do |cmd, args|
        expect(cmd).to eq("tail")
        expect(args).to include("-f")
        expect(args).to include(log_path)
      end
      object.invoke
    end
  end
end