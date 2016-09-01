module Cassie::Migration
  Version = Struct.new(:id, :version_number, :description, :migrator, :migrated_at) do
  end
end