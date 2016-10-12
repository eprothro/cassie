module Test
  class RecordByOwnerInsertQuery < Cassie::Modification

    insert_into :records_by_owner

    set :owner_id
    set :id
    set :description
  end
end