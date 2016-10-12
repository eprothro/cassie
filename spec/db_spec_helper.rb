require_relative 'support/seeds'

def red(message)
  "\e[1;31m#{message}\e[0m"
end

RSpec.configure do |config|
  # Ione is incredibly noisy :/
  config.warnings = false
end

begin
  Cassie.cluster
rescue StandardError => ex
  # let any existing STDOUT get flushed
  sleep(0.1)

  puts red("Could not connect to Cassandra Cluster. Ensure Cassandra is running.")
  puts red("  #{ex.message}")
  fail ex.class, nil, []
end

module Test

  puts "Setting up Cassandra test data"
  time = Benchmark.realtime do
    # Set up keyspace
    KeyspaceDropper.new.execute
    KeyspaceCreator.new.execute


    # Seed records
    RecordTableCreator.new.execute
    query = RecordInsertQuery.new
    (1..50).each do |i|
      query.id = i
      query.description = "Record number #{i}"
      query.execute
    end


    # Seed users
    UserTableCreator.new.execute
    query = UserInsertQuery.new
    (1..5).each do |i|
      query.id = i
      query.username = "User number #{i}"
      query.execute
    end

    # Seed records by owner
    RecordsByOwnerTableCreator.new.execute
    query = RecordByOwnerInsertQuery.new
    user_ids = (1..5).to_a
    (1..50).each do |i|
      query.owner_id = user_ids.sample
      query.id = i
      query.description = "Record number #{i}"
      query.execute
    end

    # Seed bucketed records by owner
    BucketedRecordsByOwnerTableCreator.new.execute
    query = BucketedRecordByOwnerInsertQuery.new
    query.owner_id = 1
    (1..50).each do |i|
      query.bucket = (i-1)/10
      query.id = i
      query.description = "Record number #{i}"
      query.execute
    end

    # Seed bucketed records by owner DESC order
    BucketedRecordsDescByOwnerTableCreator.new.execute
    query = BucketedRecordDescByOwnerInsertQuery.new
    query.owner_id = 1
    (1..50).each do |i|
      query.bucket = (i-1)/10
      query.id = i
      query.description = "Record number #{i}"
      query.execute
    end
  end
  puts "(#{(time*1000).round(0)}ms) Set up Cassandra test data"
end




