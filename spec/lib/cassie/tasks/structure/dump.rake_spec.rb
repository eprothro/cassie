RSpec.describe "cassie:schema:dump rake task" do
  let(:object){ Rake::Task["cassie:schema:dump"] }
  let(:argv){ [] }
  let(:buffer){ StringIO.new }
  let(:process){ double(stop: true) }

  before(:each) do
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:io){ buffer }
    allow_any_instance_of(Cassie::Tasks::IO).to receive(:argv){ argv }
    allow(Cassie::Schema).to receive(:version)
  end

  describe "#invoke" do
    it "dumps Schema" do
      expect_any_instance_of(Cassie::Schema::SchemaDumper).to receive(:dump)
      object.invoke
    end
  end
end