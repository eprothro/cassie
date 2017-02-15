require 'benchmark'

module Cassie::Schema
  require_relative 'apply_command'
  require_relative 'rollback_command'

  class Migrator
    attr_reader :target_version, :current_version, :direction
    attr_reader :commands
    attr_accessor :before_each, :after_each


    def initialize(target)
      puts target
      @target_version   = build_target_version(target)
      @current_version  = Cassie::Schema.version
      @direction        = build_direction
      @before_each      = Proc.new{}
      @after_each       = Proc.new{}
      @commands         = send("build_#{direction}_commands")
    end

    def migrate
      commands_with_callbacks do |command|
        command.execute
      end
    end

    # versions applied to the database
    # enumerated in most recent first order
    def applied_versions
      @applied_versions ||= Cassie::Schema.applied_versions.to_a
    end

    protected

    def local_versions
      Cassie::Schema.local_versions
    end

    def build_target_version(target)
      case target
      when Version
        target
      when /^[\d\.]+$/
        Version.new(target)
      when nil
        local_versions.last || Cassie::Schema.version
      else
        raise ArgumentError, "Migrator target must be a `Version` object, version string, or nil"
      end
    end

    def build_direction
      target_version >= current_version ? :up : :down
    end

    def commands_with_callbacks
      commands.each do |command|
        before_each.call(command.version, command.direction)
        duration = Benchmark.realtime do
          yield(command)
        end
        after_each.call(command.version, (duration*1000).round(2))
      end
    end

    # install all local versions since current
    #
    # a (current) | b | c | d (target) | e
    def build_up_commands
      local_versions.select{ |v| v > current_version && v <= target_version }
                    .map{ |v| ApplyCommand.new(v) }
    end

    # rollback all versions applied past the target
    # and apply missing versions to get to target
    #
    # 0 | a (target) (not applied) | b | c | d (current) | e
    def build_down_commands
      rollbacks = rollback_versions.map{ |v| RollbackCommand.new(v) }
      missing = missing_versions_before(rollbacks.last.version).map{ |v| ApplyCommand.new(v) }
      rollbacks + missing
    end

    # all versions applied since target
    # 0 | a (target) (not applied) | b | c | d (current) | e
    def rollback_versions
      applied_versions.select{ |a| a > target_version && a <= current_version }
    end

    # versions that are not applied yet
    # but need to get applied
    # to get up the target version
    #
    # | 0 (stop) | a (target) | b | c
    def missing_versions_before(last_rollback)
      return [] unless last_rollback

      rollback_index = applied_versions.index(last_rollback)

      stop = if rollback_index == applied_versions.length - 1
        # rolled back to oldest version, a rollback
        # would put us in a versionless state.
        # Any versions up to target should be applied
        Version.new('0')
      else
        applied_versions[rollback_index + 1]
      end

      return [] if stop == target_version

      local_versions.select{ |v| v > stop && v <= target_version }
    end
  end
end
