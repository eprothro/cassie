require 'support/migrations'

RSpec.describe Cassie::Schema::Migration::DownMigration do
  let(:klass){ Cassie::Schema::Migration::DownMigration }
  let(:object){ klass.new(migration) }
  let(:migration) do
    fake_migration('1')
  end
  before(:each) do
    allow(Cassie::Schema).to receive(:forget_migration){ true }
  end

  describe "migrate" do
    it "calls down" do
      expect(object).to receive(:down)
      object.migrate
    end
    it "applies version" do
      expect(Cassie::Schema).to receive(:forget_migration).with(object)
      object.migrate
    end

    context "unsuccessful up call" do
      before(:each) do
        class << migration
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
