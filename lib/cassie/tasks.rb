require 'rake'

require_relative "tasks/task_runner"
require_relative "tasks/io"
require_relative "extensions/object/color_methods"

module Cassie
  module Tasks
    Rake::TaskManager.record_task_metadata = true
    # load all tasks, but only once
    Dir.glob("#{__dir__}/tasks/**/*.rake").each do |file|
      load file
    end

    def self.io
      return @io if defined?(@io)
      $stdout
    end

    def self.io=(val)
      @io = val
    end
  end
end