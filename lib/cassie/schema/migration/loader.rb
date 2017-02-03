module Cassie::Schema
  class Migration::Loader
    attr_reader :filename, :version


    def initialize(filename)
      @filename = filename
      @version = build_version
    end

    # requires the ruby file and returns
    # the migration class defined in the file
    def load
      require filename

      begin
        klass = class_name.constantize
        klass.new(version)
      rescue NameError
        raise NameError.new("Expected #{class_name} to be defined in #{filename}, but it was not.")
      end
    end

    def class_name
      "Migration_#{version.major}_#{version.minor}_#{version.patch}_#{version.build}"
    end

    protected

    def build_version
      matches = File.basename(filename).match(/([0-9_]+)_?(.*).rb$/).captures
      version_number = matches.first.tr('_','.')
      Version.new(version_number, matches.last)
    end
  end
end
