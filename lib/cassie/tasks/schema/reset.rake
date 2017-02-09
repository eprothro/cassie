namespace :cassie do
  namespace :schema do
    desc "Creates the schema by executing the CQL in the schema file (`db/cassandra/schema.cql` by default)"
    task :reset => [:drop, :load]
  end
end