require 'support/versions'
require 'cassie/tasks'

RSpec.describe "cassie:schema:history rake task" do
  let(:object){ Rake::Task["cassie:schema:history"] }
  let(:buffer){ StringIO.new }
  let(:process){ double(running?: true) }
  let(:versions){ [fake_version(1)] }

  describe "#invoke" do
    before(:each) do
      allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
    end
    after(:each) { object.reenable }

    it "prints applied versions" do
      allow(Cassie::Schema).to receive(:applied_versions){versions}
      allow_any_instance_of(Cassie::Tasks::Schema::VersionDisplay).to receive(:print_versions) do |arg|
        expect(arg).to eq(versions)
      end
    end
  end
end