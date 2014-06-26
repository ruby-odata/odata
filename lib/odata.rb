require 'backports/2.1.0/enumerable/to_h'

require 'date'
require 'nokogiri'
require 'typhoeus'

require 'active_support'
require 'active_support/core_ext'
require 'active_support/concern'

require 'odata/version'
require 'odata/service'
require 'odata/service_registry'
require 'odata/model'

require 'odata/railtie' if defined?(::Rails)

module OData
  # Your code goes here...
end
