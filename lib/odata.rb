require 'backports/2.1.0/enumerable/to_h'

require 'date'
require 'nokogiri'
require 'typhoeus'

require 'active_support'
require 'active_support/core_ext'
require 'active_support/concern'

require 'odata/version'
require 'odata/property'
require 'odata/properties'
require 'odata/entity'
require 'odata/entity_set'
require 'odata/service'
require 'odata/service_registry'

require 'odata/railtie' if defined?(::Rails)

# The OData gem provides a convenient way to interact with OData services from
# Ruby. Please look to the {file:README.md README} for how to get started using
# the OData gem.
module OData
  # Your code goes here...
end
