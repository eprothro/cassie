namespace :cassie do
  namespace :schema do
    desc "Initiaze cassie schema versioning"
    task :init do
      include Cassie::Tasks::IO

      begin
        Cassie::Schema.initialize_versioning
        puts "[#{green("✓")}] Versioned migrations initialized. Current version: #{Cassie::Schema.version}"
      rescue Cassie::Schema::AlreadyInitiailizedError
        puts "[#{red('✘')}] Versioned migration metatdata already exists. Current version: #{Cassie::Schema.version}"
      rescue => e
        puts e.message
        exit(1)
      end
    end
  end
end