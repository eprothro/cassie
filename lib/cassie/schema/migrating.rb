module Cassie::Schema
  require_relative 'migration'
  require_relative 'migration/writer'
  require_relative 'migration/loader'
  require_relative 'migration/migrator'

  module Migrating
    def migration_files
      Dir[root.join(paths["migrations_directory"], "[0-9]*_*.rb")]
    end

    def migrations
      migrations = migration_files.map do |filename|
        Migration::Loader.new(filename).load
      end
      migrations.sort!
    end

    def next_version(bump_type=nil)
      version = migrations.max.try(:version) || Version.new('0')
      version.next_version(bump_type)
    end
  end
end