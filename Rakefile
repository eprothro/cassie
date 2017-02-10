require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)

  RSpec::Core::RakeTask.new(:full_spec) do |t|
    t.rspec_opts = "--options .rspec-full"
  end

  task :default => :spec

  Rake::Task[:build].enhance ["full_spec"]

rescue LoadError
  # no rspec available, don't add rspec tasks
end
