RSpec.describe "cassie:stop rake task" do
  let(:object){ Rake::Task["cassie:stop"] }


  describe "#invoke" do
    it "calls start on server process" do
      expect(Cassie::Support::ServerProcess).to receive(:new){double(running?: true, stop: true)}
      object.invoke
    end
  end
end