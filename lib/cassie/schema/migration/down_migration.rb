module Cassie::Schema
  class Migration
    class DownMigration < SimpleDelegator

      def direction
        :down
      end

      def migrate
        down
        remove_from_history
      end

      protected

      def remove_from_history
        Cassie::Schema.forget_migration(self)
      end
    end
  end
end