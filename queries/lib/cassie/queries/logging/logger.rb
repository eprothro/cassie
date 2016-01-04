module Cassie::Queries
  module Logging

    def self.logger
      @logger ||= init_logger
    end

    def self.logger=(new_logger)
      @logger = new_logger || Logger.new('/dev/null')
    end

    def self.init_logger(target = STDOUT)
      previous_logger = defined?(@logger) ? @logger : nil

      @logger = Logger.new(target)
      @logger.level = Logger::INFO
      @logger.formatter = log_formatter

      previous_logger.close if previous_logger
      @logger
    end

    def self.log_formatter
      ActiveSupport::Logger::SimpleFormatter.new
    end
  end
end
