module Cassie

  # Instrumentor used for notifications for events
  # such as connecting clusters, openeing sessions,
  # and executing queries
  def self.instrumenter
    @instrumenter ||= ActiveSupport::Notifications
  end
end
