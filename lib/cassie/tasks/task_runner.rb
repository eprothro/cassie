module Cassie
  module Tasks
    class TaskRunner

      def run_command(args)
        args = args.dup.select{|a| a !~ /^--/ }
        opts = args.dup.select{|a| a =~ /^--/ }
        cmd = args.delete_at(0)

        Cassie.logger.level = ::Logger::WARN unless opts.include?('--debug')

        task = "cassie:#{cmd}"
        if Rake::Task.task_defined?(task)
          Rake::Task[task].invoke(args, opts)
        else
          puts "'#{cmd}' is not a supported command.\n\n"
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