require 'support/versions'
require 'cassie/tasks'

RSpec.describe "cassie:migrations:import rake task" do
  let(:object){ Rake::Task["cassie:migrations:import"] }
  let(:buffer){ StringIO.new }
  let(:versions){ [fake_version(1)] }
  let(:importer){ double(import: true) }
  let(:options){ [] }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:options){ options }
  end

  describe "#invoke" do
    before(:each) do
      allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
    end
    after(:each) { object.reenable }

    it "calls importer" do
      expect(Cassie::Schema::CassandraMigrations::Importer).to receive(:new){importer}
      expect(importer).to receive(:import)
      object.invoke
    end
    it "passes -p option" do
    end
    it "passes -path option" do
    end
  end
end