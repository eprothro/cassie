module Cassie
  module Schema
    require_relative 'schema/configuration'
    require_relative 'schema/versioning'

    extend Configuration
    extend Versioning
  end

  require_relative 'schema/structure_dumper'
  require_relative 'schema/structure_loader'
end
