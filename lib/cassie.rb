# Active Support used for
#  * include convenience via ActiveSupport::Concern
#  * string extensions
#  * notification pub/sub
#  * log formatting
#
# We require/autoload extensions only as needed,
# this base require has almost no overhead
#
# http://guides.rubyonrails.org/active_support_core_extensions.html
require 'active_support'
require 'cassandra'

module Cassie
  require_relative 'cassie/support'
  require_relative 'cassie/logger'
  require_relative 'cassie/configuration'
  require_relative 'cassie/connection_handler'
  require_relative 'cassie/connection'
  require_relative 'cassie/query'

  extend Configuration::Core
  extend ConnectionHandler

  def self.logger
    Logger.logger
  end

  def self.logger=(logger)
    Logger.logger = logger
  end
end
