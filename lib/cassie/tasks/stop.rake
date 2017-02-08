namespace :cassie do
  desc "Stop the cassandra server process."
  task :stop do
    include Cassie::Tasks::IO

    opts = {}
    OptionParser.new do |args|
      args.on("-a", "--all", "Stop all cassandra processes, not just the server (e.g. cqlsh). Defaults to false.") do |a|
        opts[:kill_all] = a || false
      end
    end.parse!(options)

    procs = Cassie::Support::ServerProcess.all

    puts red("No Cassandra process was found. Is Cassandra running?") if procs.empty?

    if procs.length > 1 && !opts[:kill_all]
      puts red("Couldn't single out a Cassandra process.")
      puts red("  - Is cqlsh running?")
      puts red("  - Kill all cassandra processes with --all")
    else
      puts("Stopping Cassandra...")
      procs.each do |process|
        process.stop
      end
      puts "[#{green('✓')}] Cassandra Stopped"
    end
  end
end