require 'singleton'

module OData
  # Provides a registry for keeping track of multiple OData::Service instances
  class ServiceRegistry
    include Singleton

    # Add a service to the Registry
    #
    # @param service [OData::Service] service to add to the registry
    def add(service)
      initialize_instance_variables
      @services << service if service.is_a?(OData::Service) && !@services.include?(service)
      @services_by_name[service.name] = @services.find_index(service)
      @services_by_url[service.service_url] = @services.find_index(service)
    end

    # Lookup a service by URL or name
    #
    # @param lookup_key [String] the URL or name to lookup
    # @return [OData::Service, nil] the OData::Service or nil
    def [](lookup_key)
      initialize_instance_variables
      index = @services_by_name[lookup_key] || @services_by_url[lookup_key]
      index.nil? ? nil : @services[index]
    end

    # (see #add)
    def self.add(service)
      OData::ServiceRegistry.instance.add(service)
    end

    # (see #[])
    def self.[](lookup_key)
      OData::ServiceRegistry.instance[lookup_key]
    end

    private

    def initialize_instance_variables
      @services ||= []
      @services_by_name ||= {}
      @services_by_url ||= {}
    end

    def flush
      @services = []
      @services_by_name = {}
      @services_by_url = {}
    end
  end
end