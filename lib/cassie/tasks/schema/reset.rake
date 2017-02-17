namespace :cassie do
  namespace :schema do
    desc "Creates the schema by executing the schema file (`db/cassandra/schema.rb` by default)"
    task :reset => [:drop, :load]
  end
end