module OData
  # Encapsulates the basic details and functionality needed to interact with an
  # OData service.
  class Service
    # The OData Service's URL
    attr_reader :service_url

    # Opens the service based on the requested URL and adds the service to
    # {OData::Registry}
    #
    # @param service_url [String] the URL to the desired OData service
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
    # @return [OData::Service] an instance of the service
    def self.open(service_url, options = {})
      Service.new(service_url, options)
    end

    # Returns a list of entities exposed by the service
    def entities
      @entities ||= metadata.xpath('//EntityType').collect {|entity| entity.attributes['Name'].value}
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
          method: :get
      )
      request.run
      response = request.response
      feed = ::Nokogiri::XML(response.body).remove_namespaces!
      feed.xpath('//entry').collect {|entry| parse_model_from_feed(model, entry)}
    end

    private

    def default_options
      {}
    end

    def metadata
      @metadata ||= lambda {
        request = ::Typhoeus::Request.new(
            "#{service_url}/$metadata",
            method: :get
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

      attributes[:title] = {
          value: entry.xpath('//title').first.content,
          type: entry.xpath('//title').first.attributes['type'].value
      }

      attributes[:summary] = {
          value: entry.xpath('//summary').first.content,
          type: entry.xpath('//summary').first.attributes['type'].value
      }

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