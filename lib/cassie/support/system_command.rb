module Cassie
  module Support
    class SystemCommand
      attr_reader :binary, :args, :command, :status, :duration, :output

      # Indicates whether a binary exists in the current user's PATH
      # @param [String, Symbol] name the name of the command to search for
      # @return [Boolean] true if the binary could be found
      def self.exist?(name)
        !!which(name)
      end

      # Find the path to the executable file, using the current user's PATH
      # @param [String, Symbol] name the name of the command to search for
      # @return [String, nil] the fully qualified path
      def self.which(name)
        # windows support
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each { |ext|
            exe = File.join(path, "#{name}#{ext}")
            return exe if File.executable?(exe) && !File.directory?(exe)
          }
        end
        return nil
      end

      # Creates a new SystemCommand object that has
      # not yet been executed.
      #
      # @overload initialize(command)
      #   @param [#to_s] the command to execute
      #
      # @overload initialize(binary, [args]=[])
      #   @param [#to_s] binary the binary to be called
      #   @param [Array<#to_s>] args Arguments to be passed to the binary
      #
      # @overload initialize(binary, arg, ...)
      #   @param [#to_s] binary the binary to be called
      #   @param [#to_s, Array<#to_s>] arg Argument(s) to be passed to the binary
      #   @param [#to_s, Array<#to_s>] ... more argument(s) to be passed to the binary
      #
      # @example command string
      #   cmd = SystemCommand.new("git reset --hard HEAD")
      #   cmd.binary
      #   #=> "git"
      #   cmd.args
      #   #=> ["reset", "--hard", "HEAD"]
      #
      # @example binary and arguments strings
      #   cmd = SystemCommand.new("git", "reset --hard HEAD")
      #   cmd.binary
      #   #=> "git"
      #   cmd.args
      #   #=> ["reset", "--hard", "HEAD"]
      #
      # @example binary and arguments string with splat
      #   cmd = SystemCommand.new("git", "reset", "--hard HEAD")
      #   cmd.binary
      #   #=> "git"
      #   cmd.args
      #   #=> ["reset", "--hard", "HEAD"]
      #
      # @example binary with arguments array
      #   cmd = SystemCommand.new("git", ["reset", "--hard", "HEAD"])
      #   cmd.binary
      #   #=> "git"
      #   cmd.args
      #   #=> ["reset", "--hard", "HEAD"]
      #
      # @example array
      #   cmd = SystemCommand.new(["git", "reset", "--hard", "HEAD"])
      #   cmd.binary
      #   #=> "git"
      #   cmd.args
      #   #=> ["reset", "--hard", "HEAD"]
      def initialize(*cmd)
        @args = []
        cmd.flatten.each{|a| @args += a.to_s.split(" ")}

        @command = args.join(" ")
        @command = command + " 2>&1" unless command =~ / > /

        @binary = @args.shift
      end

      def exist?
        self.class.exist?(binary)
      end

      def which
        self.class.which(binary)
      end

      # Runs the command
      # @return [Boolean] true if execution completed without crashing
      def run
        t1=Time.now

        IO.popen(command) do |io|
          @status=Process.waitpid2(io.pid)[1]
          @output=io.read.sub(/\n\z/, "")
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