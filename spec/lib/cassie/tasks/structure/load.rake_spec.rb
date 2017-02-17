RSpec.describe "cassie:schema:load rake task" do
  let(:object){ Rake::Task["cassie:schema:load"] }
  let(:argv){ [] }
  let(:buffer){ StringIO.new }
  let(:process){ double(stop: true) }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:argv){ argv }
    allow(Cassie::Schema).to receive(:version)
  end

  describe "#invoke" do
    it "loads Schema" do
      expect_any_instance_of(Cassie::Schema::SchemaLoader).to receive(:load)
      object.invoke
    end
  end
end