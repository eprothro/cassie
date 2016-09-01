module Cassie
  require_relative 'migration/configuration'
  require_relative 'migration/initialization'

  module Migration
    extend Configuration
    include Initialization

    require_relative 'migration/structure_dumper'
    require_relative 'migration/structure_loader'
    require_relative 'migration/version'

    def self.version_number
      return nil unless version
      version.version_number
    end

    def self.version
      SelectVersionsQuery.new.fetch_first
    rescue Cassandra::Errors::InvalidError
      raise uninitialized_error
    end

    def self.versions
      SelectVersionsQuery.new.fetch
    rescue Cassandra::Errors::InvalidError
      raise uninitialized_error
    end
  end
end
