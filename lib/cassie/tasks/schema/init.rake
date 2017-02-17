namespace :cassie do
  namespace :schema do

    desc "Initialize versioning schema and the keyspace for this environment"
    task :init => :init_versioning do
      opts = {}
      OptionParser.new do |args|
        args.on("-v", "--version VERSION", "Set an initial schema version representing the currenet version of the schema.") do |v|
          opts[:version] = v
        end
      end.parse!(argv)

      def raise_not_found(version)
        str   =  "Version #{version} was not found locally, can't fast-forward there.\n"
        str   += "  Did you mean one of these local versions?\n" if Cassie::Schema.local_versions
        Cassie::Schema.local_versions.reverse.each do |v|
          str += "    - #{v.to_s.ljust(10)} # #{v.description}\n"
        end
        raise str
      end

      begin
        if opts[:version]
          version = Cassie::Schema::Version.new(opts[:version])
          version = Cassie::Schema.local_versions.find{|v| version == v} || raise_not_found(version)
          versions = Cassie::Schema.local_versions.select{|v| v <= version}.sort
          puts "-- Fast-forwarding to version #{version}"
            t0 = Time.now
            versions.each.with_index do |v, i|
              # space IDs out by 10 seconds to ensure they get written in order
              time = t0 - (versions.count - i * 10)
              v.id = ::Cassandra::TimeUuid::Generator.new.at(time)
              v.executor = "cassie"
              Cassie::Schema.record_version(v, false)
              puts "   > Recorded version #{v}"
            end
          puts "-- done"

        end
      rescue => e
        output_error(e)
        abort
      end
    end

    Rake::Task["cassie:schema:init"].enhance do
      Rake::Task["cassie:schema:init_keyspace"].invoke
    end
  end
end