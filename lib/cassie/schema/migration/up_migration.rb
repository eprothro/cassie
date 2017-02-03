module Cassie::Schema
  class Migration
    class UpMigration < SimpleDelegator

      def direction
        :up
      end

      def migrate
        up
        apply
      end

      protected

      def apply
        Cassie::Schema.record_migration(self)
      end
    end
  end
end