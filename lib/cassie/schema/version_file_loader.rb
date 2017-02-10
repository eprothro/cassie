require_relative 'version_loader'

module Cassie::Schema
  class VersionFileLoader < VersionLoader

    def initialize(filename)
      @filename = filename
      @version = build_version
    end

    protected

    def build_version
      unapplied_version = build_unapplied_version

      # return the applied version if it exists, since it will
      # have the full and current information about the version
      # fall back to this unapplied_version if version is not applied
      Cassie::Schema.applied_versions.find{ |v| v == unapplied_version } || unapplied_version
    rescue Cassie::Schema::UninitializedError => e
      # version cannot be applied if cassie schema meta is not initialized
      unapplied_version
    end

    def build_unapplied_version
      matches = File.basename(filename).match(/([0-9_]+)_?(.*).rb$/).captures

      number = matches.first.tr('_','.')
      description = matches.last.try(:humanize)

      Version.new(number, description).prepare_for_execution
    end
  end
end
