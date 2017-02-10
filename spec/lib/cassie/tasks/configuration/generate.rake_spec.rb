require 'support/versions'
require 'cassie/tasks'

RSpec.describe "cassie:configuration:generate rake task" do
  let(:object){ Rake::Task["cassie:configuration:generate"] }
  let(:buffer){ StringIO.new }
  let(:generator){ double(save: true, destination_path: nil) }
  let(:argv){ [] }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:argv){ argv }
  end

  describe "#invoke" do
    before(:each) do
      allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
    end
    after(:each) { object.reenable }

    it "calls importer" do
      expect(Cassie::Configuration::Generator).to receive(:new){generator}
      expect(generator).to receive(:save)
      object.invoke
    end
    it "passes -p option" do
    end
    it "passes -path option" do
    end
    it "passes -n option" do
    end
    it "passes -name option" do
    end
  end
end