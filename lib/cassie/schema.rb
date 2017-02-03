module Cassie
  module Schema
    require_relative 'schema/configuration'
    require_relative 'schema/versioning'
    require_relative 'schema/migrating'

    extend Configuration
    extend Versioning
    extend Migrating
  end

  require_relative 'schema/structure_dumper'
  require_relative 'schema/structure_loader'
end
