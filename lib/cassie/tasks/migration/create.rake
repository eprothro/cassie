require 'optparse'

namespace :cassie do
  namespace :migration do
    desc "Generates an empty migration file prefixed with the next semantic version number"
     task :create do
      include Cassie::Tasks::IO

      opts = {}
      OptionParser.new do |args|
        args.on("-b", "--build", "Bump build version number") do
          opts[:bump_type] = :build
        end
        args.on("-p", "--patch", "Bump patch version number") do
          opts[:bump_type] = :patch
        end
        args.on("-min", "--minor", "Bump minor version number") do
          opts[:bump_type] = :minor
        end
        args.on("-maj", "--major", "Bump major version number") do
          opts[:bump_type] = :major
        end
      end.parse!(options)

      begin
        name = options[0] || raise("A migration description is required:\n  $ cassie migration:create mutation_description")

        version = Cassie::Schema.next_local_version(opts[:bump_type])
        version.description = name
        puts("Creating migration for schema version #{version.number}")

        writer = Cassie::Schema::VersionWriter.new(version)
        writer.write
        rel_path = writer.filename.sub(Dir.pwd, "")
        puts green("  create #{rel_path}")
      rescue => e
        puts red("Error:\n#{e.message}")
      end
    end
  end
end

