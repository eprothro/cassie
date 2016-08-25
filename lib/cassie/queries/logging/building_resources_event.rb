module Cassie::Queries::Logging
  class BuildingResourcesEvent < ActiveSupport::Notifications::Event

    def count
      payload[:count]
    end

    def message
      {
        event: "cassie.building_resources",
        duration: duration.round(1),
        count: count
      }.extend(Inspector)
    end

    module Inspector
      def inspect
        color("(#{fetch(:duration).round(1)}ms) #{fetch(:count)} resource #{'object'.pluralize(fetch(:count))} built from Cassandra query result")
      end

      def to_s
        inspect
      end

      protected

      def color(message)
        "\e[1m\e[34m#{message}\e[0m\e[22m"
      end
    end
  end
end