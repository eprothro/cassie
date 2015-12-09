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

# Use cassie directory instead of cassie-queries
# to allow sharing of cassie module with other libraries
# but maintain folder/file/module/class naming conventions
require_relative 'cassie/query'