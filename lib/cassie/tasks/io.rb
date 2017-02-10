module Cassie::Tasks
  module IO
    def puts(*args)
      io.puts(*args)
    end

    def io
      $stdout
    end

    def argv
      ARGV
    end
  end
end