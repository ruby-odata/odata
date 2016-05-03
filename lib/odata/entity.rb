module OData
  # An OData::Entity represents a single record returned by the service. All
  # Entities have a type and belong to a specific namespace. They are written
  # back to the service via the EntitySet they came from. OData::Entity
  # instances should not be instantiated directly; instead, they should either
  # be read or instantiated from their respective OData::EntitySet.
  class Entity
    # The Entity type name
    attr_reader :type
    # The OData::Service's namespace
    attr_reader :namespace
    # The OData::Service's identifying name
    attr_reader :service_name
    # Links to other OData entitites
    attr_reader :links
    # List of errors on entity
    attr_reader :errors

    PROPERTY_NOT_LOADED = :not_loaded

    # Initializes a bare Entity
    # @param options [Hash]
    def initialize(options = {})
      @type = options[:type]
      @namespace = options[:namespace]
      @service_name = options[:service_name]
      @links = options[:links] || {}
      @errors = []
    end

    # Returns name of Entity from Service specified type.
    # @return [String]
    def name
      @name ||= type.gsub(/#{namespace}\./, '')
    end

    # Get property value
    # @param property_name [to_s]
    # @return [*]
    def [](property_name)
      if get_property(property_name).is_a?(::OData::ComplexType)
        get_property(property_name)
      else
        get_property(property_name).value
      end
    rescue NoMethodError
      raise ArgumentError, "Unknown property: #{property_name}"
    end

    # Set property value
    # @param property_name [to_s]
    # @param value [*]
    def []=(property_name, value)
      properties[property_name.to_s].value = value
    rescue NoMethodError
      raise ArgumentError, "Unknown property: #{property_name}"
    end

    def get_property(property_name)
      prop_name = property_name.to_s
      # Property is lazy loaded
      if properties_xml_value.has_key?(prop_name)
        property = instantiate_property(prop_name, properties_xml_value[prop_name])
        set_property(prop_name, property.dup)
        properties_xml_value.delete(prop_name)
      end
      properties[prop_name]
    end

    def property_names
      [@properties_xml_value.andand.keys, @properties.andand.keys].compact.flatten
    end

    def associations
      @associations ||= OData::Association::Proxy.new(self)
    end

    # Create Entity with provided properties and options.
    # @param new_properties [Hash]
    # @param options [Hash]
    # @param [OData::Entity]
    def self.with_properties(new_properties = {}, options = {})
      entity = OData::Entity.new(options)
      entity.instance_eval do
        service.properties_for_entity(name).each do |property_name, instance|
          set_property(property_name, instance)
        end

        new_properties.each do |property_name, property_value|
          self[property_name.to_s] = property_value
        end
      end
      entity
    end

    # Create Entity from XML document with provided options.
    # @param xml_doc [Nokogiri::XML]
    # @param options [Hash]
    # @return [OData::Entity]
    def self.from_xml(xml_doc, options = {})
      return nil if xml_doc.nil?
      entity = OData::Entity.new(options)
      process_properties(entity, xml_doc)
      process_feed_property(entity, xml_doc, 'title')
      process_feed_property(entity, xml_doc, 'summary')
      process_links(entity, xml_doc)
      entity
    end

    # Converts Entity to its XML representation.
    # @return [String]
    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.entry('xmlns'           => 'http://www.w3.org/2005/Atom',
                  'xmlns:data'      => 'http://schemas.microsoft.com/ado/2007/08/dataservices',
                  'xmlns:metadata'  => 'http://schemas.microsoft.com/ado/2007/08/dataservices/metadata',
                  'xmlns:georss'    => 'http://www.georss.org/georss',
                  'xmlns:gml'       => 'http://www.opengis.net/gml',
                  'xml:base'        => 'http://services.odata.org/OData/OData.svc/') do
          xml.category(term: "#{namespace}.#{type}",
                       scheme: 'http://schemas.microsoft.com/ado/2007/08/dataservices/scheme')
          xml.author { xml.name }

          xml.content(type: 'application/xml') do
            xml['metadata'].properties do
              properties.keys.each do |name|
                next if name == primary_key
                get_property(name).to_xml(xml)
              end
            end
          end
        end
      end
      builder.to_xml
    end

    # Returns the primary key for the Entity.
    # @return [String]
    def primary_key
      service.primary_key_for(name)
    end

    def is_new?
      self[primary_key].nil?
    end

    def any_errors?
      !errors.empty?
    end

    private

    def instantiate_property(property_name, value)
      value_type = service.get_property_type(name, property_name)
      klass = ::OData::PropertyRegistry[value_type]

      if klass.nil? && value_type =~ /^#{namespace}\./
        type_name = value_type.gsub(/^#{namespace}\./, '')
        property = ::OData::ComplexType.new(name: type_name, service: service)
        value.element_children.each do |node|
          property[node.name] = node.content
        end
        property
      elsif klass.nil?
        raise RuntimeError, "Unknown property type: #{value_type}"
      else
        value_content = value.content unless value.nil?
        klass.new(property_name, value_content)
      end
    end

    def properties
      @properties ||= {}
    end

    def properties_xml_value
      @properties_xml_value ||= {}
    end

    def service
      @service ||= OData::ServiceRegistry[service_name]
    end

    def set_property(name, property)
      properties[name.to_s] = property
    end

    # Instantiating properties takes time, so we can lazy load properties by passing xml_value and lookup when needed
    def set_property_lazy_load(name, xml_value )
      properties_xml_value[name.to_s] = xml_value
    end

    def self.process_properties(entity, xml_doc)
      entity.instance_eval do
        xml_doc.xpath('./content/properties/*', './properties/*').each do |property_xml|
          property_name = property_xml.name
          if property_xml.attributes['null'] &&
              property_xml.attributes['null'].value == 'true'
            xml_value = nil
          else
            xml_value = property_xml
          end
          # Doing lazy loading here because instantiating each object takes a long time
          set_property_lazy_load(property_name, xml_value)
        end
      end
    end

    def self.process_feed_property(entity, xml_doc, property_name)
      entity.instance_eval do
        xml_value = xml_doc.xpath("./#{property_name}").first
        property_name = service.send("get_#{property_name}_property_name", name)
        return if property_name.nil?
        # Doing lazy loading here because instantiating each object takes a long time
        set_property_lazy_load(property_name, xml_value)
      end
    end

    def self.process_links(entity, xml_doc)
      entity.instance_eval do
        service.navigation_properties[name].each do |nav_name, details|
          xml_doc.xpath("./link[@title='#{nav_name}']").each do |node|
            next if node.attributes['type'].nil?
            next unless node.attributes['type'].value =~ /^application\/atom\+xml;type=(feed|entry)$/i
            link_type = node.attributes['type'].value =~ /type=entry$/i ? :entry : :feed
            new_links = instance_variable_get(:@links)
            new_links[nav_name] = {
                type: link_type,
                href: node.attributes['href'].value
            }
            instance_variable_set(:@links, new_links)
          end
        end
      end
    end
  end
end
