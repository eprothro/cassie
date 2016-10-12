module Test
  class BucketedRecordsByOwnerTableCreator < Cassie::Definition

    def statement
      %(
        CREATE TABLE #{table_name} (
          owner_id int,
          bucket int,
          id int,
          description text,
          PRIMARY KEY ((owner_id, bucket), id)
        );
       )
    end

    def table_name
      "bucketed_records_by_owner"
    end
  end
end