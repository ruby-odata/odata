module OData
  class Service
    attr_reader :service_url

    def initialize(service_url)
      @service_url = service_url
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

    private

    def metadata
      @metadata ||= ::Nokogiri::XML(open("#{service_url}/$metadata")).remove_namespaces!
    end
  end
end