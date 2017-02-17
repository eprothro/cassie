module Cassie::Tasks
  module IO
    def puts(*args)
      io.puts(*args)
    end

    def output_error(exception)
      puts red("Error:  #{exception.message}")

      return unless exception.backtrace.try(:any?)

      if Cassie::Tasks::IO.trace?
        puts "  #{exception.class}:"
        puts "    #{exception.backtrace.join("\n    ")}"
      else
        puts "  (use --trace for exception info)"
      end
    end

    def io
      $stdout
    end

    def argv
      ARGV
    end

    def self.trace?
      !!@trace
    end

    def self.trace!
      @trace = true
    end
  end
end