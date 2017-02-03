module Cassie::Schema
  class ApplyCommand
    attr_reader :version

    def initialize(version)
      @version = version
    end

    def direction
      :up
    end

    def execute
      version.migration.up
      apply
    end

    protected

    def apply
      Cassie::Schema.record_version(version)
    end
  end
end