require 'support/versions'

RSpec.describe Cassie::Schema::VersionObjectLoader do
  let(:klass){ Cassie::Schema::VersionObjectLoader }
  let(:object){ klass.new(version) }
  let(:version){ Version.new(1) }

  describe "filename" do
    it "is an absolute path"
    it "is the same path that would be written to for the version"
  end
end

