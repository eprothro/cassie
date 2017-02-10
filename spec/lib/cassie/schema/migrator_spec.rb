require 'support/versions'

RSpec.describe Cassie::Schema::Migrator do
  let(:klass){ Cassie::Schema::Migrator }
  let(:object){ klass.new(target) }
  let(:target){ nil }
  let(:current_version){ Cassie::Schema::Version.new('0.0.1.0') }
  let(:versions){ [ Cassie::Schema::Version.new('0.0.1.0') ] }
  let(:local_versions) do
   [
    fake_version('0.0.1.0'),
    fake_version('0.0.2.0')
   ]
  end
  before(:each) do
    allow(Cassie::Schema).to receive(:version){ current_version }
    allow(Cassie::Schema).to receive(:applied_versions){ versions }
    allow(Cassie::Schema).to receive(:local_versions){ local_versions }
    allow(Cassie::Schema).to receive(:record_version){ true }
  end

  describe "target" do
    it "defaults to latest migration" do
      expect(object.target_version).to eq('0.0.2.0')
    end
  end

  describe "migrate" do
    let(:command){ double(execute: nil, version: nil, direction: :up) }

    it "calls execute method on commands" do
      allow(object).to receive(:commands){ [command] }
      expect(command).to receive(:execute)
      object.migrate
    end
    it "doesn't calls migration method on migrations" do
      expect(local_versions.first.migration).not_to receive(:up)
      expect(local_versions.first.migration).not_to receive(:down)
      object.migrate
    end
    it "calls callback before with migration" do
      callback = Proc.new{}
      object.before_each = callback
      expect(callback).to receive(:call).with(a_version_like(local_versions.last), :up)
      object.migrate
    end
    it "calls callback after with migration and duration" do
      class << local_versions.last.migration
        def up
          Object.class_eval("CALLED = true")
        end
      end
      callback = Proc.new{}
      object.after_each = callback
      object.migrate
      expect(Object::CALLED).to be_truthy
    end
  end

  describe "commands" do
    context "migrating up" do
      it "contains unapplied migrations" do
        expect(object.commands.last.version).to eq(local_versions.last)
      end
      it "they are decorated as UpMigrations" do
        expect(object.commands).to all be_a(Cassie::Schema::ApplyCommand)
      end
    end
    context "migrating down" do
      let(:target){ '1' }
      let(:current_version){ Cassie::Schema::Version.new('2') }
      let(:versions){ [ Cassie::Schema::Version.new('2'), Cassie::Schema::Version.new('1') ] }
      let(:local_versions) do
       [
        fake_version('1'),
        fake_version('2')
       ]
      end
      it "has elements decorated with direction" do
        expect(object.commands).to all be_a(Cassie::Schema::RollbackCommand)
      end
    end
    context "when some migrations haven't been applied" do
      let(:target){ '1' }
      let(:current_version){ Cassie::Schema::Version.new('3') }
      let(:versions){ [ Cassie::Schema::Version.new('3'), Cassie::Schema::Version.new('1') ] }
      let(:unapplied){ fake_version('2') }
      let(:migrations) do
        [
          fake_version('1'),
          unapplied,
          fake_version('3')
        ]
      end

      it "doesn't include the unapplied version" do
        expect(object.commands.map(&:version)).not_to include(a_version_like(unapplied))
      end
    end
    context "when target version isn't applied" do
      let(:target){ unapplied }
      let(:current_version){ Cassie::Schema::Version.new('3') }
      let(:versions){ [ Cassie::Schema::Version.new('3') ] }
      let(:unapplied){ fake_version('1') }
      let(:next_version){ fake_version('3') }
      let(:local_versions) do
        [
          unapplied,
          next_version
        ]
      end
      it "has rollback commands first" do
        down = object.commands[0]
        expect(down).to be_a(Cassie::Schema::RollbackCommand)
        expect(down.version).to match(a_version_like(next_version))
      end
      it "has apply commands last" do
        up = object.commands[1]
        expect(up).to be_a(Cassie::Schema::ApplyCommand)
        expect(up.version).to match(a_version_like(unapplied))
      end
    end
  end
end
