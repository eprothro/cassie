require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  RSpec::Core::RakeTask.new(:full_spec) do |t|
    t.rspec_opts = "--options .rspec-with-db"
  end

  task :default => :spec

  Rake::Task[:build].enhance ['full_spec']

  Rake::Task[:release].enhance do
    require_relative 'lib/cassie/support/command_runner'
    cmd = Cassie::Support::CommandRunner.new('gem', ['bump'])
    cmd.run!
    put cmd.output
  end
rescue LoadError
  # no rspec available, don't add rspec tasks
end
