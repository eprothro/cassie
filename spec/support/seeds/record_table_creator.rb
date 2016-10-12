module Test
  class RecordTableCreator < Cassie::Definition

    def statement
      %(
        CREATE TABLE #{table_name} (
          id int,
          description text,
          PRIMARY KEY (id)
        );
       )
    end

    def table_name
      "records"
    end
  end
end