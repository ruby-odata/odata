module OData
  class Service
    attr_reader :service_url

    def initialize(service_url)
      @service_url = service_url
      OData::ServiceRegistry.add(self)
      self
    end

    def self.open(service_url)
      Service.new(service_url)
    end

    def entities
      @entities ||= metadata.xpath('//EntityType').collect {|entity| entity.attributes['Name'].value}
    end

    def complex_types
      @complex_types ||= metadata.xpath('//ComplexType').collect {|entity| entity.attributes['Name'].value}
    end

    def namespace
      @namespace ||= metadata.xpath('//Schema').first.attributes['Namespace'].value
    end

    def inspect
      "#<#{self.class.name}:#{self.object_id} namespace='#{self.namespace}' service_url='#{self.service_url}'>"
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
  end
end