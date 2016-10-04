module Cassie::Statements

  def self.instrumenter
    @instrumenter ||= ActiveSupport::Notifications
  end
end
