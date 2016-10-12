module Test
  class RecordInsertQuery < Cassie::Modification

    insert_into :records

    set :id
    set :description
  end
end