module Cassie::Statements
  require_relative 'logging/execute_subscriber'
  require_relative 'logging/deserialize_subscriber'

  def self.logger
    @logger ||= Cassie.logger
  end

  def self.logger=(new_logger)
    @logger = new_logger || ::Logger.new('/dev/null')
  end
end
