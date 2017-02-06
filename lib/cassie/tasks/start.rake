namespace :cassie do
  desc "Start the cassandra server process in the background with reduced verbosity"
  task :start do
    runner = Cassie::Support::CommandRunner.new("cassandra")
    puts("Starting Cassandra...")
    runner.run
    runner.fail unless runner.completed?
    if runner.output =~ /state jump to NORMAL/
      puts "[#{green('✓')}] Cassandra Running"
    else
      runner.output.split("\n").grep(/ERROR/).each{|e| puts red("  " + e.gsub("; nested exception is:", "")) }
      puts "[#{red('✘')}] Cassandra Failed to Start"
    end
  end
end