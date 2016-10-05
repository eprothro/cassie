module Test
  class BucketedRecordDescByOwnerInsertQuery < Cassie::Modification

    insert_into :bucketed_records_desc_by_owner

    set :owner_id
    set :bucket
    set :id
    set :description
  end
end