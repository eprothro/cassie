module Cassie::Schema::Migration::DSL
  module Announcing
    extend ActiveSupport::Concern

    module ClassMethods
      def announcing_stream
        return @announcing_stream if defined?(@announcing_stream)
        $stdout
      end

      def announcing_stream=(val)
        @announcing_stream = val
      end
    end

    def announcing_stream
      self.class.announcing_stream
    end

    def announce(msg)
      announcing_stream << msg + "\n"
    end

    protected

    # -- Migrating 'development' schema to version 0.0.21.0
    #    - Migragting version 0.0.22.0 DOWN
    #      -> drop_table(configuration_by_context)
    #        > DROP TABLE configuration_by_context
    #   remove_column(latest_owner_id)

    # Generates output labeled with name of migration and a line that goes up
    # to 75 characters long in the terminal
    def announce_migration(message)
      text = "#{name}: #{message}"
      length = [0, 75 - text.length].max

      announce("== %s %s" % [text, "=" * length])
    end

    def announce_operation(message)
      announce("      -> " + message)
    end

    def announce_suboperation(message)
      announce("        > " + message)
    end

    def name
      version.description || version.number
    end
  end
end
