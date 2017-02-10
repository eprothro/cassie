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
        args.on("-m", "--minor", "Bump minor version number") do
          opts[:bump_type] = :minor
        end
        args.on("-M", "--major", "Bump major version number") do
          opts[:bump_type] = :major
        end
        args.on("-v", "--version VERSION", "Explicitly set version") do |v|
          opts[:version] = v
        end
      end.parse!(options)

      begin
        raise("A migration description is required.\n\nUsage:\n  cassie migration:create simple description") if options.empty?
        name = options.join(" ")

        version = Cassie::Schema::Version.new(opts[:version]) if opts[:version]
        version ||= Cassie::Schema.next_version(opts[:bump_type])
        version.description = name
        puts("-- Creating migration file for version #{version.number}")

        writer = Cassie::Schema::VersionWriter.new(version)
        writer.write
        rel_path = writer.filename.sub(Dir.pwd, "")
        puts "   > #{green('created')} #{rel_path}"
        puts "-- done"
      rescue => e
        puts red("Error:\n  #{e.message}")
        abort
      end
    end
  end
end

