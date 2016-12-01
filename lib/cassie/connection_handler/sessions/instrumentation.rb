module Cassie::ConnectionHandler::Sessions
  module Instrumentation

    protected

    def initialize_session(*args)
      Cassie.instrumenter.instrument("cassie.session.connect") do |payload|
        super(*args)
      end
    end
  end
end