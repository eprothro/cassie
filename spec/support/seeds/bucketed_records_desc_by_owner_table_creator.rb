module Test
  class BucketedRecordsDescByOwnerTableCreator < Cassie::Definition

    def statement
      %(
        CREATE TABLE #{table_name} (
          owner_id int,
          bucket int,
          id int,
          description text,
          PRIMARY KEY ((owner_id, bucket), id)
        )WITH CLUSTERING ORDER BY (id DESC);
       )
    end

    def table_name
      "bucketed_records_desc_by_owner"
    end
  end
end