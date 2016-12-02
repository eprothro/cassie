require 'support/migrations'

RSpec.describe Cassie::Schema::Migration::UpMigration do
  let(:klass){ Cassie::Schema::Migration::UpMigration }
  let(:object){ klass.new(migration) }
  let(:migration) do
    fake_migration('1')
  end

  describe "migrate" do
    it "calls up" do
      allow(Cassie::Schema).to receive(:record_migration)
      expect(object).to receive(:up)
      object.migrate
    end
    it "applies version" do
      expect(Cassie::Schema).to receive(:record_migration).with(object)
      object.migrate
    end

    context "unsuccessful up call" do
      before(:each) do
        class << migration
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
