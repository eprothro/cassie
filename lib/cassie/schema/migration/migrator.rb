require 'benchmark'

module Cassie::Schema
  class Migration
    require_relative 'up_migration'
    require_relative 'down_migration'

    class Migrator
      attr_reader :target, :current, :migrations, :direction
      attr_accessor :before_each, :after_each


      def initialize(target_number)
        @target = build_target(target_number)
        @current = Cassie::Schema.version
        @direction = target >= current ? :up : :down
        @migrations = send("select_#{direction}_migrations")
        @before_each = Proc.new{}
        @after_each = Proc.new{}
      end

      def migrate
        migrate_with_callbacks do |migration|
          migration.migrate
        end
      end

      # versions with migrations applied to the database
      # enumerated in most recent first order
      def applied_versions
        @applied_versions ||= Cassie::Schema.versions.to_a
      end

      def available_migrations
        @available_migrations = Cassie::Schema.migrations
      end

      protected

      def build_target(target_number)
        case target_number
        when Version
          target_number
        when nil
          available_migrations.last.version
        when /^[\d\.]+$/
          Version.new(target_number)
        when Migration
          target_number.version
        else
          raise ArgumentError, "version must be a Version, Migration, version string, or nil"
        end
      end

      def migrate_with_callbacks
        migrations.each do |migration|
          before_each.call(migration)
          duration = Benchmark.realtime do
            yield(migration)
          end
          after_each.call(migration, (duration*1000).round(2))
        end
      end

      # all migrations since current
      #
      # a (current) | b | c | d (target) | e
      def select_up_migrations
        available_migrations.select{ |m| m > current && m <= target }
                            .map{ |m| UpMigration.new(m) }
      end

      # all versions applied + missing migrations to get to target
      #
      # 0 | a (target) (not applied) | b | c | d (current) | e
      def select_down_migrations
        rollbacks = rollback_migrations.map{ |m| DownMigration.new(m) }
        missing = missing_migrations_before(rollbacks.last).map{ |m| UpMigration.new(m) }
        rollbacks + missing
      end

      # all versions applied since target
      # 0 | a (target) (not applied) | b | c | d (current) | e
      def rollback_migrations
        versions = applied_versions.select{ |a| a > target && a <= current }
        available_migrations.select{ |m| versions.include?(m.version) }
      end

      # migrations that are not applied yet
      # need to applied to get migrated up
      # to the target version
      #
      # | 0 (stop) | a (target) | b | c
      def missing_migrations_before(last_rollback)
        return [] unless last_rollback

        rollback_index = applied_versions.index(last_rollback.version)

        stop = if rollback_index == applied_versions.length - 1
          # rolled back to oldest version, a rollback
          # would put us in a versionless state.
          # Any migrations up to target should be applied
          Version.new('0')
        else
          applied_versions[rollback_index + 1]
        end

        return [] if stop == target

        Cassie::Schema.migrations.select{ |m| m > stop && m <= target }
      end
    end
  end
end
