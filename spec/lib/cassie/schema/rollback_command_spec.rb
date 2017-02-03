require 'support/versions'

RSpec.describe Cassie::Schema::RollbackCommand do
  let(:klass){ Cassie::Schema::RollbackCommand }
  let(:object){ klass.new(version) }
  let(:version) do
    fake_version('1')
  end
  before(:each) do
    allow(Cassie::Schema).to receive(:forget_version){ true }
  end

  describe "execute" do
    it "calls down" do
      expect(version.migration).to receive(:down)
      object.execute
    end
    it "applies version" do
      expect(Cassie::Schema).to receive(:forget_version).with(version)
      object.execute
    end

    context "unsuccessful up call" do
      before(:each) do
        class << version.migration
          def down
            raise StandardError
          end
        end
      end
      it " does not apply version" do
      end
    end
  end
end
