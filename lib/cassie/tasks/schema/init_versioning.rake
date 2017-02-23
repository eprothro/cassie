namespace :cassie do
  namespace :schema do

    desc "Initialize cassie schema versioning"
    task :init_versioning do
      include Cassie::Tasks::IO

      begin
        puts "-- Initializing Cassie Versioning"
        Cassie::Schema.initialize_versioning
        puts "   > Schema is at version #{Cassie::Schema.version}"
        puts "-- done"
      rescue => e
        output_error(e)
        abort
      end
    end
  end
end