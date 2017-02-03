module Cassie::Schema
  class RollbackCommand
    attr_reader :version

    def initialize(version)
      @version = version
    end

    def direction
      :down
    end

    def execute
      version.migration.down
      remove_from_history
    end

    protected

    def remove_from_history
      Cassie::Schema.forget_version(version)
    end
  end
end