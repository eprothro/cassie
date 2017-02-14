RSpec.describe Cassie::Schema::Versioning do
  let(:mod) { Cassie::Schema }
  let(:applied_versions) { [] }

  before(:each) do
    allow(mod).to receive(:applied_versions){ applied_versions }
  end

  describe "applied_versions" do
    it "returns versions from cassandra" do
      RSpec::Mocks.space.proxy_for(mod).reset

      allow_any_instance_of(Cassie::Schema::SelectVersionsQuery).to receive(:fetch){applied_versions}
      expect(Cassie::Schema.applied_versions).to eq(applied_versions)
    end
  end

  describe "migration_files" do
    it "lists files in config directory" do
      Dir.mktmpdir do |dir|
        mod.paths[:migrations_directory] = dir
        File.new("#{dir}/0001_test.rb", "w")
        expect(mod.send(:migration_files)).to eq(["#{dir}/0001_test.rb"])
      end
    end
  end

  describe "local_versions" do
    it "lists classes from migration files" do
      Dir.mktmpdir do |dir|
        mod.paths[:migrations_directory] = dir
        File.open("#{dir}/0001_test.rb", "w") do | file |
          file << %(
              class Migration_1_0_0_0 < Cassie::Schema::Migration
                def up
                  "up"
                end
              end
            )
        end
        File.open("#{dir}/0002_test.rb", "w") do | file |
          file << %(
              class Migration_2_0_0_0 < Cassie::Schema::Migration
                def up
                  "up 2"
                end
              end
            )
        end
        expect(mod.local_versions.first.migration.class.name).to eq('Migration_1_0_0_0')
      end
    end

    context "with incorrect class name" do
      before(:each) do
        # since we dynamically create the migration file here
        # we need to clear local_versions cache so they are reloaded
        Cassie::Schema.instance_variable_set(:@local_versions, nil)
      end

      it "raises exception with helpful description" do
        Dir.mktmpdir do |dir|
          mod.paths[:migrations_directory] = dir
          File.open("#{dir}/0099_test.rb", "w") do | file |
            file << %(
                class BadNameClass < Cassie::Schema::Migration
                end
              )
          end

          expect{mod.local_versions}.to raise_error(NameError, /0099_test.rb/)
          expect{mod.local_versions}.to raise_error(NameError, /Migration_99_0_0_0/)
        end
      end
    end

    context "when an applied version exists" do
      it "uses the applied version" do
      end
    end
  end

  describe "next_version" do
    context "when local_versions are empty" do
      before(:each) do
        allow(mod).to receive(:local_versions){[]}
      end
      it "gives 0.0.1.0 version" do
        expect(mod.next_version).to eq(Cassie::Schema::Version.new('0.0.1.0'))
      end
    end
    context "when migrations exist" do
      it "bumps max version" do
      end
      it "returns new version" do
      end
    end
    context "when current version is higher than local version" do
      it "bumps from current version" do
      end
    end
  end
end