require 'etc'
require_relative 'version_loader'

module Cassie::Schema
  class VersionObjectLoader < VersionLoader

    def initialize(version)
      @version = version
      @filename = build_filename
    end

    protected

    def build_filename
      path = VersionWriter.new(version).existing_file
      File.absolute_path(path) if path
    end
  end
end
