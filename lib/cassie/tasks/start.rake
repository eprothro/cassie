require_relative '../support/server_process'

namespace :cassie do
  desc "Start the cassandra server process in the background with reduced verbosity"
  task :start do
    include Cassie::Tasks::IO

    puts("Starting Cassandra...")
    process = Cassie::Support::ServerProcess.new

    if process.running?
      puts "[#{green('✓')}] Cassandra Running"
    else
      process.errors.each{|e| puts red("  " + e.gsub("; nested exception is:", "")) }
      puts "[#{red('✘')}] Cassandra Failed to Start"
    end
  end
end