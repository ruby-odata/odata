module OData
  class Service
    attr_reader :service_url

    def self.open(service_url)
      @service_url = service_url
    end
  end
end