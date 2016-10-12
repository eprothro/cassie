module Test
  class UserInsertQuery < Cassie::Modification

    insert_into :users

    set :id
    set :username
  end
end