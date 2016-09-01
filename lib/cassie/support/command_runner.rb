module Cassie::Support
  class CommandRunner
    attr_reader :binary, :args, :command, :status, :duration, :output

    # When a block is given, the command runs before yielding
    def initialize(binary, args=[])
      @binary = binary
      @args = args
      @command = (Array(binary) + args).join(" ")
      @command = command + " 2>&1" unless command =~ / > /

      if block_given?
        run
        yield self
      end
    end

    # Runs the command
    def run
      t1=Time.now

      IO.popen(command) do |io|
        @output=io.read
        @status=Process.waitpid2(io.pid)[1]
      end

      @duration=Time.now-t1
      completed?
    end

    # Returns false if the command hasn't been executed yet
    def run?
      !!@duration
    end

    # Returns the exit code for the command. Runs the command if it hasn't run yet.
    def exitcode
      status.exitstatus
    end

    # Returns true if exited 0
    def success?
      return false unless run?
      exitcode == 0
    end

    # Returns true if the command completed execution and success bits were set.
    # Will return false if the command hasn't been executed
    def completed?
      return false unless run?
      status.exited? && @status.success?
    end

    def failure_message
      msg = "---------------------\n"
      msg << red(output)
      msg << "---------------------\n"
      msg << "Failed to execute `#{command}`:\n"
      msg << "\tPlease check the output above for any errors and make sure that `#{binary}` is installed in your PATH with proper permissions."
      msg
    end

    protected

    def red(message)
      "\e[1m\e[31m#{message}\e[0m\e[22m"
    end
  end
end