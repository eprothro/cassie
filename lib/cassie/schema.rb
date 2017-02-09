module Cassie
  # Contains interface and components for managing
  # Cassandra schema using semantically versioned,
  # incremental migration files.
  #
  # * Versioned migration files are stored in-repo in ruby files defining +up+ and +down+ mutation methods.
  # * Data about what migrations have been applied is stored in Cassandra persistence.
  # * The schema state is stored in an in-repo schema file that contains the CQL required to recreate the current schema state/version from scratch.
  # * Various +cassie+ executable commands provide an interface to manage migrations and versioning.
  #
  # Run +cassie --help+ to see a list of commands and their descriptions for managing the schema through versioned migrations.
  #
  # @see file:lib/cassie/schema/README.md Schema README for information on task usage and the migration DSL.
  module Schema
    require_relative 'schema/configuration'
    require_relative 'schema/versioning'

    extend Configuration
    extend Versioning
  end

  require_relative 'schema/structure_dumper'
  require_relative 'schema/structure_loader'
end
