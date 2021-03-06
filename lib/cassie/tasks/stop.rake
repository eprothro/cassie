namespace :cassie do
  desc "Stop the cassandra server process."
  task :stop do
    include Cassie::Tasks::IO

    opts = {}
    OptionParser.new do |args|
      args.on("-a", "--all", "Stop all cassandra processes, not just the server (e.g. cqlsh). Defaults to false.") do
        opts[:kill_all] = true
      end
    end.parse!(argv)

    procs = Cassie::Support::ServerProcess.all

    if procs.empty?
      puts red("No Cassandra process was found. Is Cassandra running?")
      abort
    end

    if procs.length > 1 && !opts[:kill_all]
      puts red("Couldn't single out a Cassandra process.")
      puts red("  - Is cqlsh running?")
      puts red("  - Kill all cassandra processes with --all")
      abort
    else
      puts("Stopping Cassandra...")
      procs.each do |process|
        process.stop
      end
      puts "[#{green('✓')}] Cassandra Stopped"
    end
  end
end