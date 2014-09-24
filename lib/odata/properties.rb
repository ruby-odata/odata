# Modules
require 'odata/properties/number'

# Implementations
require 'odata/properties/binary'
require 'odata/properties/boolean'
require 'odata/properties/date_time'
require 'odata/properties/date_time_offset'
require 'odata/properties/decimal'
require 'odata/properties/float'
require 'odata/properties/guid'
require 'odata/properties/integer'
require 'odata/properties/string'
require 'odata/properties/time'
require 'odata/properties/geography_point'

OData::Properties.constants.each do |property_name|
  klass = OData::Properties.const_get(property_name)
  if klass.is_a?(Class)
    property = klass.new('test', nil)
    OData::PropertyRegistry.add(property.type, property.class)
  end
end