require 'support/versions'

RSpec.describe Cassie::Schema::VersionFileLoader do
  let(:klass){ Cassie::Schema::VersionFileLoader }
  let(:object){ klass.new(filename) }
  let(:filename){ "0000_0001.rb" }
  let(:applied_versions){ [] }

  before(:each) do
    allow(Cassie::Schema).to receive(:applied_versions){ applied_versions }
  end

  describe "version" do
    context "when the version hasn't been applied" do
      context "with description in file name" do
        let(:filename){ "0000_0001_description_test.rb" }

        it "has humanized description" do
          expect(object.version.description).to eq("Description test")
        end

        it "has version" do
          expect(object.version.number).to eq("0.1.0.0")
        end
      end
    end
    context "when the version has been applied" do
      let(:version){ fake_version(1) }
      let(:applied_versions){ [ version ] }
      let(:filename){ "1.rb" }

      it "reutrns applied version" do
        expect(object.version).to equal(version)
      end
    end
  end
end

