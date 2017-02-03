require 'support/versions'

RSpec.describe Cassie::Schema::ApplyCommand do
  let(:klass){ Cassie::Schema::ApplyCommand }
  let(:object){ klass.new(version) }
  let(:version) do
    fake_version('1')
  end

  describe "execute" do
    it "calls up" do
      allow(Cassie::Schema).to receive(:record_version)
      expect(version.migration).to receive(:up)
      object.execute
    end
    it "applies version" do
      expect(Cassie::Schema).to receive(:record_version).with(version)
      object.execute
    end

    context "unsuccessful up call" do
      before(:each) do
        class << version.migration
          def up
            raise StandardError
          end
        end
      end
      it " does not apply version" do
      end
    end
  end
end
