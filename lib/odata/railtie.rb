module OData # :nodoc:
  class Railtie < Rails::Railtie
    config.before_initialize do
      ::OData::Railtie.load_configuration!
      ::OData::Railtie.setup_service_registry!
    end

    def self.load_configuration!
      # load environment config from config/odata.yml
    end

    def self.setup_service_registry!
      # use configuration to setup registry of OData::Services
    end
  end
end