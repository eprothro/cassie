namespace :cassie do
  namespace :schema do
    desc "Migrates the schema by running the `up` methods for any migrations starting after the current schema version"
    task :migrate do
      include Cassie::Tasks::IO

      begin
        version = options[0]

        migrator = Cassie::Schema::Migrator.new(version)
        puts "-- Migrating to version #{migrator.target_version}"

        if migrator.commands.count == 0
          if migrator.target_version == migrator.current_version
            puts "   > Already at #{migrator.target_version}, nothing to do..."
          else
            raise "No migration files found to migrate to #{migrator.target_version}, staying at #{migrator.current_version}"
          end
        else
          migrator.before_each = Proc.new do |v, direction|
            puts "   - Migragting version #{v} #{direction.upcase}"
          end
          migrator.after_each = Proc.new do |_migration, duration|
            puts "   - done (#{duration} ms)"
          end
          migrator.migrate
          puts "-- done"
        end
      rescue => e
        puts red("Error:\n  #{e.message}")
        abort
      end
    end
  end
  desc "alias for schema:migrate"
  task :migrate => "schema:migrate"
end

Rake::Task["cassie:schema:migrate"].enhance do
  Rake::Task["cassie:schema:dump"].invoke
end