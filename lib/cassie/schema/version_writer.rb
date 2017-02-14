require 'fileutils'

module Cassie::Schema
  class VersionWriter
    attr_reader :io
    attr_reader :version

    attr_accessor :up_code
    attr_accessor :down_code

    def initialize(version, io=nil)
      @io = io
      @version = version
      @up_code = default_up_code
      @down_code = default_down_code

      ensure_dir_exist
    end

    # Writes the version's migration clas code to a new
    # ruby migraton file in the
    # +Cassie::Schema.paths[:migrations_directory]+
    # @return [String] the filename of the path written
    # @raise [IOError] if a file with a matching version already exists
    def write
      with_io do |io|
        io << migration_contents
      end
    end

    def with_io
      if io.respond_to?(:<<)
        yield io
      else
        ensure_unique_version
        File.open(filename, 'w'){ |file| yield file }
        # load the file, so the definition for source
        # for the methods will come from that file
        # instead of (eval)
        load File.absolute_path(filename)
        filename
      end
    end

    def migration_contents=(contents)
      @migration_contents = contents
    end

    def migration_contents
      return @migration_contents if defined?(@migration_contents)
      build_migration_contents
    end

    def filename
      "#{directory}/#{basename}"
    end

    def directory
      Cassie::Schema.paths[:migrations_directory]
    end

    def basename
      "#{version_prefix}#{description_suffix}.rb"
    end

    def existing_file
      Dir.glob("#{directory}/#{version_prefix}*.rb").first
    end

    protected

    def ensure_dir_exist
      FileUtils.makedirs(directory) unless File.directory?(directory)
    end

    def ensure_unique_version
      if existing_file
        raise IOError.new("A migration already exists for #{version.parts.join('.')} in #{existing_file}. Try bumping the version.")
      end
    end

    def build_migration_contents
      return @migration_contents if defined?(@migration_contents)
      <<-EOS
class #{version.migration_class_name} < Cassie::Schema::Migration
  def up
    #{up_code}
  end

  def down
    #{down_code}
  end
end
      EOS
    end

    def version_prefix
      version.parts.map{|p| p.to_s.rjust(4, "0") }.join('_')
    end

    def description_suffix
      return nil unless version.description
      "_" + version.description.parameterize('_')
    end

    def default_up_code
      "# Code to execute when applying this migration"
    end

    def default_down_code
      "# Code to execute when rolling back this migration"
    end
  end
end
