module Cassie
  module Tasks
    class TaskRunner

      def run_command(args)
        cmd = args.delete_at(0) if args.first !~ /^-/
        task = "cassie:#{cmd}"

        Cassie.logger.level = ::Logger::WARN unless args.delete('--debug')

        if Rake::Task.task_defined?(task)
          Rake::Task[task].invoke
        else
          puts "'#{cmd}' is not a supported command.\n\n" unless args.delete('--help')
          print_documentation
        end
      end

      def print_documentation
        docs = <<-EOS
Usage:
  cassie <command> [options]

Commands:
EOS
        Rake.application.tasks.each do |task|
          docs += "  #{task.name.sub('cassie:','').ljust(25)} # #{task.comment}\n"
        end


        puts docs
      end
    end
  end
end