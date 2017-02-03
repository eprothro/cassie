require 'fileutils'

module Cassie::Schema
  class VersionWriter
    attr_reader :io
    attr_reader :version
    attr_accessor :migration_contents

    def initialize(version, io=nil)
      @version = version
      @migration_contents = default_migration_contents
      @io = io
      ensure_dir_exist
    end

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
      end
    end

    def filename
      "#{directory}/#{basename}"
    end

    def directory
      Cassie::Schema.paths["migrations_directory"]
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

    def default_migration_contents
      <<-EOS
class #{version.migration_class_name} < Cassie::Schema::Migration
  def up
    # Code to execute when executing this migration
  end

  def down
    # Code to execute when rolling back this migration
  end
end
      EOS
    end

    def version_prefix
      version.parts.map{|p| p.to_s.rjust(4, "0") }.join('_')
    end

    def description_suffix
      return nil unless version.description

      "_" + version.description.underscore
    end
  end
end