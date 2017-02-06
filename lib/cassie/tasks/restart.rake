namespace :cassie do
  desc "Stop and restart the cassandra server process"
  task :restart => [:stop, :start] do
  end
end