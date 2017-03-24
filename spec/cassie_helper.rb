# Cassie specific configuration for gem testing
Cassie.env = 'test'
Cassie.logger.level = ::Logger::WARN
require 'cassie/testing'
require_relative 'break_cassandra_connection'