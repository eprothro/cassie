require 'support/versions'
require 'cassie/tasks'

RSpec.describe "cassie:schema:init rake task" do
  let(:object){ Rake::Task["cassie:schema:init"] }
  let(:buffer){ StringIO.new }
  let(:argv){ [] }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:argv){ argv }
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:abort){ nil }
  end

  describe "#invoke" do
    before(:each) do
      allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }

      init_v = Rake::Task["cassie:schema:init_versioning"]
      init_ks = Rake::Task["cassie:schema:init_keyspace"]

      allow(init_v).to receive(:invoke)
      allow(init_ks).to receive(:invoke)

      object.reenable
    end

    it "initializes versioning" do
      expect(object.prerequisite_tasks).to include(Rake::Task["cassie:schema:init_versioning"])
    end

    it "initializes the keyspace" do
      expect(Rake::Task["cassie:schema:init_keyspace"]).to receive(:invoke)

      object.invoke
    end

    context "with -v option" do
      let(:argv){ ["-v", version_number] }
      let(:version_number){ "2" }
      let(:version){ Cassie::Schema::Version.new(version_number) }
      let(:versions){ [fake_version(1), fake_version(2), fake_version(3),] }

      before(:each) do
        allow(Cassie::Schema).to receive(:local_versions){ versions }
      end

      it "records versions up to version" do
        recorderd = []
        expect(Cassie::Schema).to receive(:record_version).twice do |v|
          recorderd << v
        end

        object.invoke

        expect(recorderd).to eq([fake_version(1), fake_version(2)])
      end
    end

  end
end