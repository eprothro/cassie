namespace :cassie do
  desc "Tail the cassandra server logs"
  task :tail do
    runner = Cassie::Support::SystemCommand.new("which", ["cassandra"])
    runner.run!

    bin_path = runner.output.tr("\n", '')
    log_path = bin_path.sub('bin/cassandra', 'logs/system.log')
    puts white("Tailing Cassandra system log, Ctrl-C to stop...")
    puts "  #{log_path}:\n\n"

    args = ['-f', log_path, '>', '/dev/tty']
    runner = Cassie::Support::SystemCommand.new("tail", args)
    runner.run!
  end
end