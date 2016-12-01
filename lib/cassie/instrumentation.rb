module Cassie
  def self.instrumenter
    @instrumenter ||= ActiveSupport::Notifications
  end
end
