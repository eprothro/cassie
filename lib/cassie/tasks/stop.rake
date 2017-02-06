namespace :cassie do
  desc "Stop the cassandra server process."
  task :stop do
    opts = {}
    OptionParser.new do |args|
      args.on("-a", "--all", "Stop all cassandra processes, not just the server (e.g. cqlsh). Defaults to false.") do |a|
        opts[:kill_all] = a || false
      end
    end.parse!

    runner = Cassie::Support::CommandRunner.new("ps", ["-awx"])
    runner.run
    fail runner.failure_message unless runner.success?

    cassandra_awx = runner.output.split("\n").grep(/cassandra/)
    pids = cassandra_awx.map{ |p| p.split(' ').first.to_i }

    if pids.empty?
      puts red("No Cassandra process was found. Is Cassandra running?")
      exit(1)
    elsif pids.length > 1 && !opts[:kill_all]
      puts red("Couldn't single out a Cassandra process.")
      puts red("  - Is cqlsh running?")
      puts red("  - Kill all cassandra processes with --all")
      cassandra_awx.each do |p|
        puts "    - #{p.split(' ').first.ljust(5,' ')} | #{p.split(' ').last}"
      end
      exit(1)
    end

    puts("Stopping Cassandra...")
    pids.each do|pid|
      Process.kill("TERM", pid)
      loop do
        sleep(0.1)
        begin
          Process.getpgid( pid )
        rescue Errno::ESRCH
          break
        end
      end
    end

    puts "[#{green('✓')}] Cassandra Stopped"
  end
end