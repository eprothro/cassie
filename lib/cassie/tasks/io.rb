module Cassie::Tasks
  module IO
    def puts(*args)
      Cassie::Tasks.io.puts(*args)
    end
  end
end