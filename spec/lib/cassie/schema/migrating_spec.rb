RSpec.describe Cassie::Schema::Migrating do
  let(:mod) { Cassie::Schema }

  describe "migration_files" do
    it "lists files in config directory" do
      Dir.mktmpdir do |dir|
        mod.paths["migrations_directory"] = dir
        File.new("#{dir}/0001_test.rb", "w")
        expect(mod.migration_files).to eq(["#{dir}/0001_test.rb"])
      end
    end
  end

  describe "migrations" do
    it "lists classes from migration files" do
      Dir.mktmpdir do |dir|
        mod.paths["migrations_directory"] = dir
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
        expect(mod.migrations.first.class.name).to eq('Migration_1_0_0_0')
      end
    end



    context "with incorrect class name" do
      it "raises exception with helpful description" do
        Dir.mktmpdir do |dir|
          mod.paths["migrations_directory"] = dir
          File.open("#{dir}/0099_test.rb", "w") do | file |
            file << %(
                class BadNameClass < Cassie::Schema::Migration
                end
              )
          end

          expect{mod.migrations}.to raise_error(NameError, /0099_test.rb/)
          expect{mod.migrations}.to raise_error(NameError, /Migration_99_0_0_0/)
        end
      end
    end
  end

  describe "next_version" do
    context "when migrations are empty" do
      before(:each) do
        allow(mod).to receive(:migrations){[]}
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
  end
end