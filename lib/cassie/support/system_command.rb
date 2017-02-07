module Cassie
  module Support
    class SystemCommand
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
      # @return [Boolean] true if execution completed without crashing
      def run
        t1=Time.now

        IO.popen(command) do |io|
          @output=io.read
          @status=Process.waitpid2(io.pid)[1]
        end

        @duration=Time.now-t1
        completed?
      end

      # Runs the command, expecting an exit status of 0
      # @return [Boolean] true if execution completed without crashing
      # @raise [RuntimeError] if program was not run successfully
      def succeed
        fail unless run && success?

        true
      end

      # @return [Boolean] false if the command hasn't been run yet
      def run?
        !!@duration
      end

      # Runs the command if it hasn't been run yet.
      # @return [Fixnum] the exit code for the command.
      def exitcode
        status.exitstatus
      end

      # @return [Boolean] true if command has been run, and exited with status of 0,
      #                   otherwise returns false.
      def success?
        return false unless run?
        exitcode == 0
      end

      # @return [Boolean] true if the command completed execution and success bits were set, regardless of the exit status code.
      #                   false if the command hasn't been executed, failed to exit, or crashed.
      def completed?
        return false unless run?
        status.exited? && @status.success? #status.success is NOT the exit code == 0!
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

      # raise a Runtime error with a failure message
      # specific to the command
      def fail
        raise RuntimeError.new(failure_message)
      end

      def red(message)
        "\e[1m\e[31m#{message}\e[0m\e[22m"
      end
    end
  end
end