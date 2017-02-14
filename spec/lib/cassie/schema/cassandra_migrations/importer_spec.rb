require 'support/versions'
require 'support/cassandra_migrations/migration_file'

RSpec.describe Cassie::Schema::CassandraMigrations::Importer do
  let(:klass){ Cassie::Schema::CassandraMigrations::Importer }
  let(:object){ klass.new(source_path) }
  let(:source_path) { nil }
  let(:migrations_dir){ Dir.mktmpdir }
  let(:migration_files){ [fake_migration_file] }

  before(:each) do
    allow(Cassie::Schema).to receive(:paths){ {migrations_directory: migrations_dir} }
    allow(object).to receive(:migration_files){ migration_files }
  end

  describe "import" do
    xit "writes a new migration file" do
    end
    xit "records version" do
      expect(Cassie::Schema).to receive(:record_version)
      object.import
    end
  end
end
