def instrumented_event_for(notification)
  event = nil
  subscription = ActiveSupport::Notifications.subscribe notification do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
  end

  yield

  ActiveSupport::Notifications.unsubscribe(subscription)

  event
end