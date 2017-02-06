require 'optparse'

namespace :cassie do
  namespace :configuration do
    desc "Generate a sample cassandra configuration file"
    task :generate do
      opts = {}
      OptionParser.new do |args|
        args.on("-p", "--path", "Path to place configuration file. Defaults to './config/cassandra.yml'") do |p|
          opts[:destination_path] = if path[0] == "/"
            path
          else
            File.join(Dir.pwd, path)
          end
        end
        args.on("-n", "--name", "Application name. Used as prefix for keyspace names. Defaults to 'my_app'") do |n|
          opts[:app_name] = n
        end
      end.parse!

      generator = Cassie::Configuration::Generator.new(opts)
      generator.save
      puts "[✓] Cassandra configuration written to #{generator.destination_path}"
    end
  end
end