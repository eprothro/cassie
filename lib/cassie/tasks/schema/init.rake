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

      not_found = Proc.new do
        str   =  "Version #{version} was not found locally, can't fast-forward there."
        str   += "  Did you mean one of these local versions?" if Cassie::Schema.local_versions
        Cassie::Schema.local_versions.reverse.each do |v|
          str += "    - #{v.to_s.ljust(10)} # #{v.description}"
        end
        raise str
      end

      begin
        if opts[:version]
          version = Cassie::Schema::Version.new(opts[:version])
          version = Cassie::Schema.local_versions.find(not_found){|v| version == v}
          versions = Cassie::Schema.local_versions.select{|v| v <= version}.sort
          puts "-- Fast-forwarding to version #{version}"
            versions.each do |v|
              Cassie::Schema.record_version(v, false)
              puts "   > Recorded version #{version}"
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