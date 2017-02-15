require 'rake'
require 'active_support/core_ext/string'

require_relative "tasks/task_runner"
require_relative "tasks/io"
require_relative "extensions/object/color_methods"

module Cassie
  # Various modules and classes for use with executables.
  # These classes are not loaded by +require 'cassie'+.
  # Execute +require 'cassie/tasks' if they are needed in an application.
  module Tasks
    Rake::TaskManager.record_task_metadata = true
    # load all tasks, but only once
    Dir.glob("#{__dir__}/tasks/**/*.rake").each do |file|
      load file
    end
  end
end