module Test
  class UserTableCreator < Cassie::Definition

    def statement
      %(
        CREATE TABLE #{table_name} (
          id int,
          username text,
          PRIMARY KEY (id)
        );
       )
    end

    def table_name
      "users"
    end
  end
end