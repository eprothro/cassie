module Cassie::Schema
  class Migration
    require_relative 'migration/cassandra_support'

    include Comparable
    include CassandraSupport

    attr_reader :version

    def initialize(version=nil)
      @version = version || build_version
    end

    def <=>(other)
      compare = case other
      when Version
        other
      when Migration
        other.version
      else
        other
      end
      version.<=>(compare)
    end

    protected

    def build_version
      method = self.method(:up) || self.method(:down)
      if method && File.exist?(method.source_location.first)
        Loader.new(method.source_location.first).version
      else
        version_name = self.class.name.match(/Migration_(.*)/).captures.first
        Version.new(version_name.tr('_','.'))
      end
    end
  end
end