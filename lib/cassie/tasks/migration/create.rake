require 'optparse'

namespace :cassie do
  namespace :migration do
    desc "Generates an empty migration file prefixed with the next semantic version number"
    task :create do
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
      end.parse!
      name = ARGV[1]

      version = Cassie::Schema.next_local_version(opts[:bump_type])
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
  end
end

