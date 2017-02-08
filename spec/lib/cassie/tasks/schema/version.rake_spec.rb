require 'support/versions'
require 'cassie/tasks'

RSpec.describe "cassie:schema:version rake task" do
  let(:object){ Rake::Task["cassie:schema:version"] }
  let(:buffer){ StringIO.new }
  let(:version){ fake_version(rand(10000)) }

  describe "#invoke" do
    before(:each) do
      allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
    end
    after(:each) { object.reenable }

    it "prints current version" do
      allow(Cassie::Schema).to receive(:version){version}
      expect_any_instance_of(Cassie::Tasks::Schema::VersionDisplay).to receive(:print_versions) do |main, v|
        # note: rspec bug passing 'main' as 1st arg.
        expect(v).to eq([version])
      end
      object.invoke
    end
  end
end