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

    # Returns a list of entities exposed by the service
    def entity_types
      @entity_types ||= metadata.xpath('//EntityType').collect {|entity| entity.attributes['Name'].value}
    end

    # Returns a hash of EntitySet names keyed to their respective EntityType name
    def entity_sets
      @entity_sets ||= metadata.xpath('//EntityContainer/EntitySet').collect {|entity|
        [
          entity.attributes['EntityType'].value.gsub("#{namespace}.", ''),
          entity.attributes['Name'].value
        ]
      }.to_h
    end

    # Returns a list of ComplexTypes used by the service
    def complex_types
      @complex_types ||= metadata.xpath('//ComplexType').collect {|entity| entity.attributes['Name'].value}
    end

    # Returns the namespace defined on the service's schema
    def namespace
      @namespace ||= metadata.xpath('//Schema').first.attributes['Namespace'].value
    end

    # Returns a more compact inspection of the service object
    def inspect
      "#<#{self.class.name}:#{self.object_id} namespace='#{self.namespace}' service_url='#{self.service_url}'>"
    end

    # Handles getting OData resources from the service.
    #
    # @param model [OData::Model] the type of resource being requested
    # @param criteria [Hash] any criteria to narrow the request
    # @return [Array] instances of the requested model
    def get(model, criteria = {})
      request = ::Typhoeus::Request.new(
          build_request_url(model, criteria),
          options[:typhoeus].merge({
            method: :get
          })
      )
      request.run
      response = request.response
      feed = ::Nokogiri::XML(response.body).remove_namespaces!
      feed.xpath('//entry').collect {|entry| parse_model_from_feed(model, entry)}
    end

    # Retrieves the EntitySet associated with a specific EntityType by name
    #
    # @param entity_type_name [to_s] the name of the EntityType you want the EntitySet of
    # @return [OData::EntitySet] an OData::EntitySet to query
    def [](entity_type_name)
      xpath_query = "//EntityContainer/EntitySet[@EntityType='#{namespace}.#{entity_type_name}']"
      entity_set_node = metadata.xpath(xpath_query).first
      set_name = entity_set_node.attributes['Name'].value
      container_name = entity_set_node.parent.attributes['Name'].value
      OData::EntitySet.new(name: set_name, namespace: namespace, type: entity_type_name.to_s, container: container_name)
    end

    private

    def default_options
      {
          typhoeus: {}
      }
    end

    def metadata
      @metadata ||= lambda {
        request = ::Typhoeus::Request.new(
            "#{service_url}/$metadata",
            options[:typhoeus].merge({
              method: :get
            })
        )
        request.run
        response = request.response
        ::Nokogiri::XML(response.body).remove_namespaces!
      }.call
    end

    def build_request_url(model, criteria)
      request_url = "#{service_url}/#{model.odata_name}"
      request_url += "(#{criteria[:key]})" if criteria[:key]
      request_url
    end

    def parse_model_from_feed(model, entry)
      attributes = {}

      %w{title summary}.each do |attribute_name|
        attributes[attribute_name.to_sym] = {
            value: entry.xpath("//#{attribute_name}").first.content,
            type: entry.xpath("//#{attribute_name}").first.attributes['type'].value
        }
      end

      entry.xpath('//content/properties/*').each do |property|
        if property.attributes['null']
          if property.attributes['null'].value == 'true'
            property_type = nil
          else
            property_type = property.attributes['type'].value
          end
        else
          property_type = property.attributes['type'].value
        end

        attributes[property.name.underscore.to_sym] = {
            value: property.content,
            type: property_type
        }
      end

      model.load_from_feed(attributes)
    end
  end
end