require 'singleton'

module OData
  class ServiceRegistry
    include Singleton

    def add(service)
      initialize_instance_variables
      @services << service if service.is_a?(OData::Service) && !@services.include?(service)
      @services_by_namespace[service.namespace] = @services.find_index(service)
      @services_by_url[service.service_url] = @services.find_index(service)
    end

    def [](lookup_key)
      initialize_instance_variables
      index = @services_by_namespace[lookup_key] || @services_by_url[lookup_key]
      index.nil? ? nil : @services[index]
    end

    def self.add(service)
      OData::ServiceRegistry.instance.add(service)
    end

    def self.[](lookup_key)
      OData::ServiceRegistry.instance[lookup_key]
    end

    private

    def initialize_instance_variables
      @services ||= []
      @services_by_namespace ||= {}
      @services_by_url ||= {}
    end

    def flush
      @services = []
      @services_by_namespace = {}
      @services_by_url = {}
    end
  end
end