module Cassie::Support
  class CommandRunner
    attr_reader :binary, :args, :command, :process, :duration, :output

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
        @process=Process.waitpid2(io.pid)[1]
      end

      @duration=Time.now-t1
      exitcode == 0
    end

    # Runs the command and raises if doesn't exit 0
    def run!
      Kernel.fail error_message unless exitcode == 0
    end

    # Returns false if the command hasn't been executed yet
    def run?
      !!process
    end

    # Returns the exit code for the command. Runs the command if it hasn't run yet.
    def exitcode
      ensure_run
      process.exitstatus
    end

    # Returns true if the command completed execution.
    # Will return false if the command hasn't been executed
    def finished?
      return false unless process
      process.success?
    end

    protected

    def ensure_run
      run unless process
    end

    def error_message
      msg = "\n"
      msg << color(output)
      msg << "\n---------------------"
      msg << "\n\nfailed to execute `#{command}`.\n"
      msg << "Please check the output above for any errors and make sure that `#{binary}` is installed in your PATH with proper permissions.\n"
      msg
    end

    def color(message)
      "\e[1m\e[31m#{message}\e[0m\e[22m"
    end
  end
end