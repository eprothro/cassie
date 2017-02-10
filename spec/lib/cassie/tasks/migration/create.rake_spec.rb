require 'support/versions'
require 'cassie/tasks'

RSpec.describe "cassie:migration:create rake task" do
  let(:object){ Rake::Task["cassie:migration:create"] }
  let(:buffer){ StringIO.new }
  let(:version){ fake_version(rand(1000)) }
  let(:writer){ double(write: true, filename: "") }
  let(:options){ ["some_description"] }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:options){ options }
  end

  describe "#invoke" do
    before(:each) do
      allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
      allow(Cassie::Schema).to receive(:next_version){version}
    end
    after(:each) { object.reenable }

    context "when keyspace exists" do
      before(:each) do
        allow(Cassie).to receive(:keyspace_exists?){ true }
      end

      it "calls writer" do
        expect_any_instance_of(Cassie::Schema::VersionWriter).to receive(:write)
        object.invoke
      end
      it "uses next version" do
        allow(Cassie::Schema).to receive(:next_version){ version }
        expect(Cassie::Schema::VersionWriter).to receive(:new){ writer } do |v|
          expect(v).to eq(version)
        end
        object.invoke
      end
    end
  end
end