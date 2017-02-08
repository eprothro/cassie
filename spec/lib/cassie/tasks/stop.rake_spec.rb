RSpec.describe "cassie:stop rake task" do
  let(:object){ Rake::Task["cassie:stop"] }
  let(:options){ [] }
  let(:process){ double(stop: true) }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:options){ options }
  end

  describe "#invoke" do
    context "when a sever process exists" do
      before(:each) do
       allow(Cassie::Support::ServerProcess).to receive(:all){ [process] }
     end
      it "calls start on server process" do
        expect(process).to receive(:stop)
        object.invoke
      end
    end
  end
end