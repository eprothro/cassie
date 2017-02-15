require 'optparse'

namespace :cassie do
  namespace :configuration do
    desc "Generate a sample cassandra configuration file"
    task :generate do
      include Cassie::Tasks::IO

      begin
        opts = {}
        OptionParser.new do |args|
          args.on("-p", "--path PATH", "Path to place configuration file. Defaults to './config/cassandra.yml'") do |p|
            opts[:destination_path] = if p[0] == "/"
              p
            else
              File.join(Dir.pwd, p)
            end
          end
          args.on("-n", "--name NAME", "Application name. Used as prefix for keyspace names. Defaults to 'my_app'") do |n|
            opts[:app_name] = n
          end
        end.parse!(argv)

        puts "-- Generating sample cassie cluster configuration file"
        generator = Cassie::Configuration::Generator.new(opts)
        generator.save
        puts "   > #{green("created")} #{generator.destination_path}"
        puts "-- done"
      rescue => e
        output_error(e)
        abort
      end
    end
  end
end