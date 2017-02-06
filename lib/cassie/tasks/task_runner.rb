module Cassie
  module Tasks
    class TaskRunner
      def start
        runner = Cassie::Support::CommandRunner.new("cassandra")
        puts("Starting Cassandra...")
        runner.run
        runner.fail unless runner.completed?

        if runner.output =~ /state jump to NORMAL/
          puts "[#{green('✓')}] Cassandra Running"
        else
          runner.output.split("\n").grep(/ERROR/).each{|e| puts red("  " + e.gsub("; nested exception is:", "")) }
          puts "[#{red('✘')}] Cassandra Failed to Start"
        end
      end

      def stop(kill_all=false)
        runner = Cassie::Support::CommandRunner.new("ps", ["-awx"])
        runner.run
        fail runner.failure_message unless runner.success?

        cassandra_awx = runner.output.split("\n").grep(/cassandra/)
        pids = cassandra_awx.map{ |p| p.split(' ').first.to_i }

        if pids.empty?
          puts red("No Cassandra process was found. Is Cassandra running?")
          exit(1)
        elsif pids.length > 1 && !kill_all
          puts red("Couldn't single out a Cassandra process.")
          puts red("  - Is cqlsh running?")
          puts red("  - Kill all cassandra processes with --all")
          cassandra_awx.each do |p|
            puts "    - #{p.split(' ').first.ljust(5,' ')} | #{p.split(' ').last}"
          end
          exit(1)
        end

        puts("Stopping Cassandra...")
        pids.each do|pid|
          Process.kill("TERM", pid)
          loop do
            sleep(0.1)
            begin
              Process.getpgid( pid )
            rescue Errno::ESRCH
              break
            end
          end
        end

        puts "[#{green('✓')}] Cassandra Stopped"
      end

      def kick
        stop
        start
      end

      def generate_config(path, name)
        opts = {}
        if path
          opts[:destination_path] = if path[0] == "/"
            # cassie configuration:generate /usr/var/my_config_dir/cassandra_db.yml
            path
          else
            # cassie configuration:generate my_config_dir/cassandra_db.yml
            File.join(Dir.pwd, path)
          end
        end
        opts[:app_name]         = name if name

        generator = Cassie::Configuration::Generator.new(opts)
        generator.save
        puts "[✓] Cassandra configuration written to #{generator.destination_path}"
      end

      def dump_structure
        dumper = Cassie::Schema::StructureDumper.new
        dumper.dump
        puts "[#{green("✓")}] Cassandra schema written to #{dumper.destination_path}"

      rescue => e
        puts e.message
        exit(1)
      end

      def load_structure
        loader = Cassie::Schema::StructureLoader.new
        loader.load
        puts "[#{green("✓")}] Cassandra schema loaded from #{loader.source_path}"

      rescue => e
        puts e.message
        exit(1)
      end

      def tail_log
        runner = Cassie::Support::CommandRunner.new("which", ["cassandra"])
        runner.run!

        bin_path = runner.output.tr("\n", '')
        log_path = bin_path.sub('bin/cassandra', 'logs/system.log')
        puts white("Tailing Cassandra system log, Ctrl-C to stop...")
        puts "  #{log_path}:\n\n"

        args = ['-f', log_path, '>', '/dev/tty']
        runner = Cassie::Support::CommandRunner.new("tail", args)
        runner.run!
      end

      # Use current schema to initialize versioned migrations
      #   * import current schema as initial migration
      #   * initialize cassie_schema keyspace and version table
      #   * insert initial version
      #   * dump structure
      def initialize_migrations
        Cassie::Schema.initialize_versioning
        puts "[#{green("✓")}] Versioned migrations initialized. Current version: #{Cassie::Schema.version}"
      rescue Cassie::Schema::AlreadyInitiailizedError
        puts "[#{red('✘')}] Versioned migration metatdata already exists. Current version: #{Cassie::Schema.version}"
      rescue => e
        puts e.message
        exit(1)
      end

      def schema_history
        print_versions(Cassie::Schema.applied_versions)
      rescue Cassie::Schema::UninitializedError => e
        puts red(e.message)
      end

      def schema_version
        print_versions([Cassie::Schema.version])
      rescue Cassie::Schema::UninitializedError => e
        puts red(e.message)
      end

      def drop_schema

      end

      def create_migration(name, bump_type)
        version = Cassie::Schema.next_local_version(bump_type)
        version.description = name
        puts("Creating migration for schema version #{version.number}")
        begin
          writer = Cassie::Schema::VersionWriter.new(version)
          writer.write
          rel_path = writer.filename.sub(Dir.pwd, "")
          puts green("  create #{rel_path}")
        rescue IOError => e
          puts red(e.message)
        end
      end

      def import_schema(keyspace)
        Cassie::Schema::Migration::CassandraImporter.new(keyspace)

        importer.import
      end

      def import_migrations(path)
        require_relative '../lib/cassie/schema/cassandra_migrations/importer'

        importer = Cassie::Schema::CassandraMigrations::Importer.new(path)

        importer.import

      end

      def migrate(version)

        migrator = Cassie::Schema::Migrator.new(version)

        migrator.before_each = Proc.new do |version, direction|
          puts "-- Migragting #{direction}: #{version}"
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

      def print_versions(versions)
        require 'terminal-table'
        members = [:number, :description, :executor, :executed_at]
        titles  = ['Number', 'Description', 'Migrated by', 'Migrated at']
        table = Terminal::Table.new(headings:  titles)

        versions.each.with_index do |v, i|
          row = v.to_h.values_at(*members)
          row[0] = "* #{row[0]}" if i == 0
          table.add_row(row)
        end

        table.align_column(0, :right)
        puts table
      end

      def white(message)
        "\e[1;37m#{message}\e[0m"
      end

      def red(message)
        "\e[1;31m#{message}\e[0m"
      end

      def green(message)
        "\e[1;32m#{message}\e[0m"
      end

      def run_command(args)
        args = args.dup.select{|a| a !~ /^--/ }
        opts = args.dup.select{|a| a =~ /^--/ }
        cmd = args.delete_at(0)

        Cassie.logger.level = ::Logger::WARN unless opts.include?('--debug')

        case cmd
        when "start"
          start
        when "stop"
          stop(opts.include?('--all'))
        when /kick|restart/
          kick
        when /tail|log/
          tail_log
        when /config(uration)?:generate/
          generate_config(args[0], args[1])
        when "structure:dump"
          dump_structure
        when "structure:load"
          load_structure
        when /migrations?\:initialize/
          initialize_migrations
        when "schema:history"
          schema_history
        when "schema:version"
          schema_version
        when "schema:drop"
          drop_schema
        when "migration:create"
          bump = nil
          bump = :minor if opts.delete('--minor')
          bump = :major if opts.delete('--major')
          bump = :patch if opts.delete('--patch')
          bump = :build if opts.delete('--build')

          create_migration(args.first, bump)
        when /(schema:)?migrate/
          migrate(args.first)
        when /schema:import/
          import_schema(args.first)
        when /migrations:import/
          import_migrations(args.first)
        else
          puts red("`#{cmd}` is not a supported command.")
        end
      end

      def print_documentation
        docs = <<-EOS
Usage:
  cassie <command> [options]

Commands:
  start                                           # Starts the cassandra server process
  stop [--all]                                    # Stops the cassandra server process. Optionally, stops all Cassandra processes (e.g. including cqlsh)
  reset | kick                                    # Stops and then starts the cassandra sever process.
  tail                                            # Tails the cassandra server logs
  configuration:generate [file path] [app name]   # Generate a sample cassandra config file
  migrations:import [migrations directory path]   # Import existing `cassandra_migrations` migration files and convert to semantic versioning
  migration:create                                # Generates an empty migration file prefixed with the next semantic version number
  migrate | schema:migrate                        # Migrates the schema by running the `up` methods in any migrations starting after the current schema version
  migrate:reset | schema:migrate:reset            # Runs schema:reset and migrate
  schema:version                                  # Print the current schema version information for the Cassandra cluster
  schema:history                                  # Print the the historical version information the current Cassandra cluster state
  schema:status                                   # Print the the migration status for each local migration (up/down)
  schema:load                                     # Loads current schema from structure.cql
  schema:drop                                     # Drop keyspace(s)
  schema:reset                                    # Runs schema:drop and schema:loa
  schema:import                                   # Create an initial migration based on the current Cassandra non-system schema
  structure:dump                                  # Dumps the schema for all non-system keyspaces in CQL format (`db/cassandra/structure.cql` by default)
  structure:load                                  # Creates the schema by executing the CQL schema in the structure file (`db/cassandra/structure.cql` by default)
EOS

        puts docs
      end
    end
  end
end