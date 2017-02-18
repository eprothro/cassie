require 'support/versions'
require 'cassie/tasks'

RSpec.describe "cassie:schema:drop rake task" do
  let(:object){ Rake::Task["cassie:schema:drop"] }
  let(:buffer){ StringIO.new }
  let(:argv){ [] }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:argv){ argv }
  end

  describe "#invoke" do
    before(:each) do
      allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
      allow(Cassie).to receive(:keyspace_exists?){ true }
    end
    after(:each) { object.reenable }

    it "deletes from cassandra" do
      allow(Cassie::Schema).to receive(:applied_versions){[]}
      expect_any_instance_of(Cassie::Schema::DropKeyspaceQuery).to receive(:execute!)
      expect_any_instance_of(Cassie::Schema::DeleteVersionQuery).to receive(:execute!)
      object.invoke
    end
  end
end