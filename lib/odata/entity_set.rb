module OData
  class EntitySet
    attr_reader :name, :type, :namespace, :container

    def initialize(options = {})
      @name = options[:name]
      @type = options[:type]
      @namespace = options[:namespace]
      @container = options[:container]
    end
  end
end