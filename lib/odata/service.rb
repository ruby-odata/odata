module OData
  # Encapsulates the basic details and functionality needed to interact with an
  # OData service.
  class Service
    # The OData Service's URL
    attr_reader :service_url
    # Options to pass around
    attr_reader :options

    # Opens the service based on the requested URL and adds the service to
    # {OData::Registry}
    #
    # @param service_url [String] the URL to the desired OData service
    # @param options [Hash] options to pass to the service
    # @return [OData::Service] an instance of the service
    def initialize(service_url, options = {})
      @service_url = service_url
      @options = default_options.merge(options)
      OData::ServiceRegistry.add(self)
      self
    end

    # Opens the service based on the requested URL and adds the service to
    # {OData::Registry}
    #
    # @param service_url [String] the URL to the desired OData service
    # @param options [Hash] options to pass to the service
    # @return [OData::Service] an instance of the service
    def self.open(service_url, options = {})
      Service.new(service_url, options)
    end

    # Returns user supplied name for service, or its URL
    # @return [String]
    def name
      @name ||= options[:name] || service_url
    end

    # Returns a list of entities exposed by the service
    def entity_types
      @entity_types ||= metadata.xpath('//EntityType').collect {|entity| entity.attributes['Name'].value}
    end

    # Returns a hash of EntitySet names keyed to their respective EntityType name
    def entity_sets
      @entity_sets ||= Hash[metadata.xpath('//EntityContainer/EntitySet').collect {|entity|
        [
          entity.attributes['Name'].value,
          entity.attributes['EntityType'].value.gsub("#{namespace}.", '')
        ]
      }]
    end

    # Returns a list of ComplexTypes used by the service
    def complex_types
      @complex_types ||= metadata.xpath('//ComplexType').collect {|entity| entity.attributes['Name'].value}
    end

    # Returns the associations defined by the service
    # @return [Hash<OData::Association>]
    def associations
      @associations ||= Hash[metadata.xpath('//Association').collect do |association_definition|
        [
            association_definition.attributes['Name'].value,
            build_association(association_definition)
        ]
      end]
    end

    # Returns a hash for finding an association through an entity type's defined
    # NavigationProperty elements.
    # @return [Hash<Hash<OData::Association>>]
    def navigation_properties
      @navigation_properties ||= Hash[metadata.xpath('//EntityType').collect do |entity_type_def|
        entity_type_name = entity_type_def.attributes['Name'].value
        [
            entity_type_name,
            Hash[entity_type_def.xpath('./NavigationProperty').collect do |nav_property_def|
              relationship_name = nav_property_def.attributes['Relationship'].value
              relationship_name.gsub!(/^#{namespace}\./, '')
              [
                  nav_property_def.attributes['Name'].value,
                  associations[relationship_name]
              ]
            end]
        ]
      end]
    end

    # Returns the namespace defined on the service's schema
    def namespace
      @namespace ||= metadata.xpath('//Schema').first.attributes['Namespace'].value
    end

    # Returns a more compact inspection of the service object
    def inspect
      "#<#{self.class.name}:#{self.object_id} name='#{name}' service_url='#{self.service_url}'>"
    end

    # Retrieves the EntitySet associated with a specific EntityType by name
    #
    # @param entity_set_name [to_s] the name of the EntitySet desired
    # @return [OData::EntitySet] an OData::EntitySet to query
    def [](entity_set_name)
      xpath_query = "//EntityContainer/EntitySet[@Name='#{entity_set_name}']"
      entity_set_node = metadata.xpath(xpath_query).first
      raise ArgumentError, "Unknown Entity Set: #{entity_set_name}" if entity_set_node.nil?
      container_name = entity_set_node.parent.attributes['Name'].value
      entity_type_name = entity_set_node.attributes['EntityType'].value.gsub(/#{namespace}\./, '')
      OData::EntitySet.new(name: entity_set_name,
                           namespace: namespace,
                           type: entity_type_name.to_s,
                           service_name: name,
                           container: container_name)
    end

    # Execute a request against the service
    #
    # @param url_chunk [to_s] string to append to service url
    # @param additional_options [Hash] options to pass to Typhoeus
    # @return [Typhoeus::Response]
    def execute(url_chunk, additional_options = {})
      request = ::Typhoeus::Request.new(
          URI.escape("#{service_url}/#{url_chunk}"),
          options[:typhoeus].merge({
            method: :get
          }).merge(additional_options)
      )
      request.run
      request.response
    end

    # Find a specific node in the given result set
    #
    # @param results [Typhoeus::Response]
    # @return [Nokogiri::XML::Element]
    def find_node(results, node_name)
      document = ::Nokogiri::XML(results.body)
      document.remove_namespaces!
      document.xpath("//#{node_name}").first
    end

    # Find entity entries in a result set
    #
    # @param results [Typhoeus::Response]
    # @return [Nokogiri::XML::NodeSet]
    def find_entities(results)
      document = ::Nokogiri::XML(results.body)
      document.remove_namespaces!
      document.xpath('//entry')
    end

    # Get the property type for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @param property_name [to_s] the property name needed
    # @return [String] the name of the property's type
    def get_property_type(entity_name, property_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@Name='#{property_name}']").first.attributes['Type'].value
    end

    # Get the property used as the title for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @return [String] the name of the property used as the entity title
    def get_title_property_name(entity_name)
      node = metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@FC_TargetPath='SyndicationTitle']").first
      node.nil? ? nil : node.attributes['Name'].value
    end

    # Get the property used as the summary for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @return [String] the name of the property used as the entity summary
    def get_summary_property_name(entity_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@FC_TargetPath='SyndicationSummary']").first.attributes['Name'].value
    rescue NoMethodError
      nil
    end

    # Get the primary key for the supplied Entity.
    #
    # @param entity_name [to_s]
    # @return [String]
    def primary_key_for(entity_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Key/PropertyRef").first.attributes['Name'].value
    end

    # Get the list of properties and their various options for the supplied
    # Entity name.
    # @param entity_name [to_s]
    # @return [Hash]
    # @api private
    def properties_for_entity(entity_name)
      type_definition = metadata.xpath("//EntityType[@Name='#{entity_name}']").first
      raise ArgumentError, "Unknown EntityType: #{entity_name}" if type_definition.nil?
      properties_to_return = {}
      type_definition.xpath('./Property').each do |property_xml|
        property_name, property = process_property_from_xml(property_xml)
        properties_to_return[property_name] = property
      end
      properties_to_return
    end

    # Get list of properties and their various options for the supplied
    # ComplexType name.
    # @param type_name [to_s]
    # @return [Hash]
    # @api private
    def properties_for_complex_type(type_name)
      type_definition = metadata.xpath("//ComplexType[@Name='#{type_name}']").first
      raise ArgumentError, "Unknown ComplexType: #{type_name}" if type_definition.nil?
      properties_to_return = {}
      type_definition.xpath('./Property').each do |property_xml|
        property_name, property = process_property_from_xml(property_xml)
        properties_to_return[property_name] = property
      end
      properties_to_return
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end

    def logger=(custom_logger)
      @logger = custom_logger
    end

    private

    def default_options
      {
          typhoeus: {
              headers: { 'DataServiceVersion' => '3.0' }
          }
      }
    end

    def metadata
      @metadata ||= lambda {
        request = ::Typhoeus::Request.new(
            URI.escape("#{service_url}/$metadata"),
            options[:typhoeus].merge({
              method: :get
            })
        )
        request.run
        response = request.response
        ::Nokogiri::XML(response.body).remove_namespaces!
      }.call
    end

    def process_property_from_xml(property_xml)
      property_name = property_xml.attributes['Name'].value
      value_type = property_xml.attributes['Type'].value
      property_options = {}

      klass = ::OData::PropertyRegistry[value_type]

      if klass.nil? && value_type =~ /^#{namespace}\./
        type_name = value_type.gsub(/^#{namespace}\./, '')
        property = ::OData::ComplexType.new(name: type_name, service: self)
      elsif klass.nil?
        raise RuntimeError, "Unknown property type: #{value_type}"
      else
        property_options[:allows_nil] = false if property_xml.attributes['Nullable'] == 'false'
        property = klass.new(property_name, nil, property_options)
      end

      return [property_name, property]
    end

    def build_association(association_definition)
      options = {
        name: association_definition.attributes['Name'].value,
        ends: build_association_ends(association_definition.xpath('./End'))
      }
      ::OData::Association.new(options)
    end

    def build_association_ends(end_definitions)
      end_definitions.collect do |end_definition|
        options = {
          entity_type:  end_definition.attributes['Type'].value,
          multiplicity: end_definition.attributes['Multiplicity'].value
        }
        ::OData::Association::End.new(options)
      end
    end
  end
end
