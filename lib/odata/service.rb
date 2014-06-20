module OData
  # Encapsulates the basic details and functionality needed to interact with an
  # OData service.
  class Service
    # The OData Service's URL
    attr_reader :service_url

    # (see #open)
    def initialize(service_url)
      @service_url = service_url
      OData::ServiceRegistry.add(self)
      self
    end

    # Opens the service based on the requested URL
    # @param service_url [String] the URL to the desired OData service
    # @return [OData::Service] an instance of the service
    def self.open(service_url)
      Service.new(service_url)
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
      feed.xpath('//entry')
    end

    private

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
  end
end