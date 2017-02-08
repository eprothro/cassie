require 'support/versions'
require 'cassie/tasks'

RSpec.describe "cassie:migration:create rake task" do
  let(:object){ Rake::Task["cassie:migration:create"] }
  let(:buffer){ StringIO.new }
  let(:version){ fake_version(rand(1000)) }
  let(:writer){ double(write: true, filename: "") }
  let(:options){ [] }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:options){ options }
  end

  describe "#invoke" do
    before(:each) do
      allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
      allow(Cassie::Schema).to receive(:next_local_version){version}
    end
    after(:each) { object.reenable }

    it "calls writer" do
      expect_any_instance_of(Cassie::Schema::VersionWriter).to receive(:write)
      object.invoke
    end
    it "uses next version" do
      expect(Cassie::Schema::VersionWriter).to receive(:new){ writer } do |v|
        expect(v).to eq(Cassie::Schema.next_local_version)
      end
      object.invoke
    end
  end
end