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
  require_relative 'cassie/query'
  require_relative 'cassie/configuration'
  require_relative 'cassie/connection_handler'
  require_relative 'cassie/connection'

  extend Configuration::Core
  extend ConnectionHandler
end
