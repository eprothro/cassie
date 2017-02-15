module Cassie
  module Tasks
    class TaskRunner
      attr_reader :raw_args
      attr_reader :args
      attr_reader :command
      attr_reader :options

      def initialize(raw_args)
        @raw_args = raw_args
        @args = raw_args.dup
        @command = nil
        @command = args.delete_at(0) if args.first =~ /\A[^-]/
        @options = {}
      end

      def run
        build_options
        Cassie.logger.level = ::Logger::WARN unless options[:debug]

        run_command || display_info
      rescue OptionParser::InvalidOption => e
        puts("#{e.message}\n\n")
        display_info
      end

      # @returns [Boolean] if task was invoked
      def run_command
        task && task.invoke
      end

      # @returns [Rake::Task, nil] nil if task is not defined, otherwise the task object itself
      def task
        task_name = "cassie:#{command}"
        Rake::Task[task_name] if Rake::Task.task_defined?(task_name)
      end

      def display_info
        case
        when command && !task
          puts "'#{command}' is not a supported command.\n\n"
          print_documentation
        when options[:show_help]
          print_documentation
        when options[:show_version]
          puts Cassie::VERSION
        else
          print_documentation
        end
      end

      protected

      def print_documentation
        docs = <<-EOS
Usage:
  cassie <command> [options]

Commands:
EOS
        Rake.application.tasks.each do |task|
          docs += "  #{task.name.sub('cassie:','').ljust(25)} # #{task.comment}\n"
        end
        docs += <<-EOS

Options:
  -h, --help                # Print this documentation
  -v, --version             # List the library version
  -d, --debug               # Show debug log lines
  <command> --help          # List options for a given command
  <command> --trace         # Show exception backtrace

EOS

        puts docs
      end

      def build_options
        @options.tap do |h|
          # Options Parsers doesn't work well unles
          # all options are passed up to a single parser.
          # Since we don't want to shadow options and we
          # do want sub-task --help to work
          #
          # As is, a sub task with dependencies
          # may cause issues since the pre-task could
          # have optiosn that cause a parsing error.
          # Need to revisit and probably ditch rake tasks.
          h[:trace] = args.delete("-t") || args.delete("--trace")
          h[:debug] = args.delete("-d") || args.delete("--debug")
          h[:show_version] = args.include?("-v") || args.include?("--version")
          h[:show_help] = args.include?("-h") || args.include?("--help")
        end
      end
    end
  end
end