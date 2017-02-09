namespace :cassie do
  namespace :schema do
    desc "Migrates the schema by running the `up` methods for any migrations starting after the current schema version"
    task :migrate do
      include Cassie::Tasks::IO

      version = ARGV[0]

      migrator = Cassie::Schema::Migrator.new(version)

      migrator.before_each = Proc.new do |v, direction|
        puts "-- Migragting #{direction}: #{v}"
      end

      migrator.after_each = Proc.new do |_migration, duration|
        puts "-- done (#{duration} ms)"
      end

      if migrator.commands.count == 0
        if migrator.target_version == migrator.current_version
          puts "Already at #{migrator.target_version}, no migrations to process..."
        else
          puts "No migrations found to migrate to #{migrator.target_version}, staying at #{migrator.current_version}"
        end
      else
        puts "Migrating #{migrator.direction} to schema version #{migrator.target_version}:"
        migrator.migrate
        puts "\nMigration complete. Schema is at #{migrator.target_version}"
      end
    end
  end
  desc "alias for schema:migrate"
  task :migrate => "schema:migrate"
end

Rake::Task["cassie:schema:migrate"].enhance do
  Rake::Task["cassie:schema:dump"].invoke
end