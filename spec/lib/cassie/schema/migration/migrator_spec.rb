require 'support/migrations'

RSpec.describe Cassie::Schema::Migration::Migrator do
  let(:klass){ Cassie::Schema::Migration::Migrator }
  let(:object){ klass.new(target) }
  let(:target){ nil }
  let(:current_version){ Cassie::Schema::Version.new('0.0.1.0') }
  let(:versions){ [ Cassie::Schema::Version.new('0.0.1.0') ] }
  let(:migrations) do
   [
    fake_migration('0.0.1.0'),
    fake_migration('0.0.2.0')
   ]
  end
  before(:each) do
    allow(Cassie::Schema).to receive(:version){ current_version }
    allow(Cassie::Schema).to receive(:versions){ versions }
    allow(Cassie::Schema).to receive(:migrations){ migrations }
    allow(Cassie::Schema).to receive(:record_migration){ true }
  end

  describe "target" do
    it "defaults to latest migration" do
      expect(object.target).to eq('0.0.2.0')
    end
  end

  describe "migrate" do
    let(:migration){ double(migrate: nil) }

    it "calls migration method on migrations" do
      allow(object).to receive(:migrations){ [migration] }
      expect(migration).to receive(:migrate)
      object.migrate
    end
    it "doesn't calls migration method on migrations" do
      expect(migrations.first).not_to receive(:up)
      expect(migrations.first).not_to receive(:down)
      object.migrate
    end
    it "calls callback before with migration" do
      callback = Proc.new{}
      object.before_each = callback
      expect(callback).to receive(:call).with(a_migration_like(migrations.last))
      object.migrate
    end
    it "calls callback after with migration and duration" do
      class << migrations.last
        def up
          sleep(0.002)
        end
      end
      callback = Proc.new{}
      object.after_each = callback
      expect(callback).to receive(:call).with(a_migration_like(migrations.last), a_number_close_to(2, 0.8))
      object.migrate
    end
  end

  describe "migrations" do
    context "migrating up" do
      it "contains unapplied migrations" do
        expect(object.migrations).to eq([migrations.last])
      end
      it "they are decorated as UpMigrations" do
        expect(object.migrations).to all be_a(Cassie::Schema::Migration::UpMigration)
      end
    end
    context "migrating down" do
      let(:target){ '1' }
      let(:current_version){ Cassie::Schema::Version.new('2') }
      let(:versions){ [ Cassie::Schema::Version.new('2'), Cassie::Schema::Version.new('1') ] }
      let(:migrations) do
       [
        fake_migration('1'),
        fake_migration('2')
       ]
      end
      it "has elements decorated with direction" do
        expect(object.migrations).to all be_a(Cassie::Schema::Migration::DownMigration)
      end
    end
    context "when some migrations haven't been applied" do
      let(:target){ '1' }
      let(:current_version){ Cassie::Schema::Version.new('3') }
      let(:versions){ [ Cassie::Schema::Version.new('3'), Cassie::Schema::Version.new('1') ] }
      let(:unapplied){ fake_migration('2') }
      let(:migrations) do
        [
          fake_migration('1'),
          unapplied,
          fake_migration('3')
        ]
      end

      it "doesn't include the unapplied migration" do
        expect(object.migrations).not_to include(a_migration_like(unapplied))
      end
    end
    context "when target migration isn't applied" do
      let(:target){ unapplied }
      let(:current_version){ Cassie::Schema::Version.new('3') }
      let(:versions){ [ Cassie::Schema::Version.new('3') ] }
      let(:unapplied){ fake_migration('1') }
      let(:current_migration){ fake_migration('3') }
      let(:migrations) do
        [
          unapplied,
          current_migration
        ]
      end
      it "has down migrations first" do
        down = object.migrations[0]
        expect(down).to be_a(Cassie::Schema::Migration::DownMigration)
        expect(down).to match(a_migration_like(current_migration))
      end
      it "has up migrations last" do
        up = object.migrations[1]
        expect(up).to be_a(Cassie::Schema::Migration::UpMigration)
        expect(up).to match(a_migration_like(unapplied))
      end
    end
  end
end
