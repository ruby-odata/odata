module OData
  class Railtie < Rails::Railtie
    config.before_initialize do
      ::OData::Railtie.load_configuration!
      ::OData::Railtie.setup_service_registry!
    end

    # Looks for config/odata.yml and loads the configuration.
    def self.load_configuration!
      # TODO Implement Rails configuration loading
    end

    # Examines the loaded configuration and populates the
    # OData::ServiceRegistry accordingly.
    def self.setup_service_registry!
      # TODO Populate OData::ServiceRegistry based on configuration
    end
  end
end