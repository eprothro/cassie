require 'etc'

module Cassie::Schema
  class VersionLoader
    attr_reader :filename, :version

    # Requires the ruby file, thus loading the Migration class into the ObjectSpace.
    #
    # @returns The Version object if successful. In other words, if
    #   object representing the version returns a Cassie::Schema::Migration object.
    #   Otherwise returns false.
    #
    # @raise [NameError] if the migration class could not be loaded
    def load
      require filename

      begin
        # ensure the migration class is now defined
        version.migration_class_name.constantize
        if version.migration.is_a?(Cassie::Schema::Migration)
          version
        else
          false
        end
      rescue NameError
        raise NameError.new("Expected #{version.migration_class_name} to be defined in #{filename}, but it was not.")
      end
    end
  end
end
