require 'singleton'

module OData
  # Provides a registry for keeping track of various property types used by
  # OData.
  class PropertyRegistry
    include Singleton

    # Add a property type to the registry
    #
    # @param type_name [String] property type name to register
    # @param klass [Class] Ruby class to use for the specified type
    def add(type_name, klass)
      properties[type_name] = klass
    end

    # Lookup a property by name and get the Ruby class to use for its instances
    #
    # @param type_name [String] the type name to lookup
    # @return [Class, nil] the proper class or nil
    def [](type_name)
      properties[type_name]
    end

    # (see #add)
    def self.add(type_name, klass)
      OData::PropertyRegistry.instance.add(type_name, klass)
    end

    # (see #[])
    def self.[](type_name)
      OData::PropertyRegistry.instance[type_name]
    end

    private

    def properties
      @properties ||= {}
    end
  end
end