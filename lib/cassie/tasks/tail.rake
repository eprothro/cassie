namespace :cassie do
  desc "Tail the cassandra server logs"
  task :tail do
    include Cassie::Tasks::IO

    log_path = Cassie::Support::ServerProcess.log_path
    puts white("Tailing Cassandra system log, Ctrl-C to stop...")
    puts "  #{log_path}:\n\n"

    args = ['-f', log_path, '>', '/dev/tty']
    tail = Cassie::Support::SystemCommand.new("tail", args)
    tail.run
  end
end