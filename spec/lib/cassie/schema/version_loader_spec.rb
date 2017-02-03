require 'support/versions'

RSpec.describe Cassie::Schema::VersionLoader do
  let(:klass){ Cassie::Schema::VersionLoader }
  let(:object) do
    o = klass.new
    o.version = version
    o.filename = filename
  end
  let(:version){ Version.new(1) }
  let(:filename){ "" }

  before(:each) do
    allow(Cassie::Schema).to receive(:applied_versions){ applied_versions }
  end

  describe "load" do
    context "when the file defines the class" do
      it "returns the version class" do
      end
      it "makes the migration object available" do
      end
    end
    context "when the file doesn't define the correct class" do
      it "raises an exception"
    end
    context "when the file doesn't define a migration class" do
      it "returns false"
    end
  end
end

