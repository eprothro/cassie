RSpec.describe "cassie:stop rake task" do
  let(:object){ Rake::Task["cassie:stop"] }
  let(:options){ [] }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:options){ options }
  end

  describe "#invoke" do
    it "calls start on server process" do
      expect(Cassie::Support::ServerProcess).to receive(:new){double(running?: true, stop: true)}
      object.invoke
    end
  end
end