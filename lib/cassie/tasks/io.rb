module Cassie::Tasks
  module IO
    def puts(*args)
      io.puts(*args)
    end

    def io
      $stdout
    end

    def options
      ARGV
    end
  end
end