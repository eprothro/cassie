module Test
  class RecordsByOwnerTableCreator < Cassie::Definition

    def statement
      %(
        CREATE TABLE #{table_name} (
          owner_id int,
          id int,
          description text,
          PRIMARY KEY (id)
        );
       )
    end

    def table_name
      "records_by_owner"
    end
  end
end