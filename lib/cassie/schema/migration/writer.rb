require 'fileutils'

module Cassie::Schema
  class Migration::Writer
    attr_reader :io
    attr_reader :version

    def initialize(version, io=nil)
      @version = version
      @io = io
    end

    def write
      with_io do |io|
        io << contents
      end
    end

    def class_name
      "Migration_#{version.major}_#{version.minor}_#{version.patch}_#{version.build}"
    end

    def with_io
      if io.respond_to?(:<<)
        yield io
      else
        ensure_unique_version
        ensure_dir_exist
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

    protected

    def ensure_dir_exist
      FileUtils.makedirs(directory) unless File.directory?(directory)
    end

    def ensure_unique_version
      if match = Dir.glob("#{directory}/#{version_prefix}*.rb").first
        raise IOError.new("A migration already exists for #{version.parts.join('.')} in #{match}. Try bumping the version.")
      end
    end

    def contents
      <<-EOS
class #{class_name} < Cassie::Schema::Migration
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
