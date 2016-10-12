module Test
  class BucketedRecordByOwnerInsertQuery < Cassie::Modification

    insert_into :bucketed_records_by_owner

    set :owner_id
    set :bucket
    set :id
    set :description
  end
end