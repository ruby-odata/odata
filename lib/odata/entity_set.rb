module OData
  class EntitySet
    include Enumerable

    attr_reader :name, :type, :namespace, :container

    # Sets up the EntitySet to permit querying for the resources in the set.
    #
    # @param options [Hash] the options to setup the EntitySet
    # @return [OData::EntitySet] an instance of the EntitySet
    def initialize(options = {})
      @name = options[:name]
      @type = options[:type]
      @namespace = options[:namespace]
      @container = options[:container]
      self
    end

    # Provided for Enumerable functionality
    def each(&block)
      # entities.each do |entity|
      #   if block_given?
      #     block.call entity
      #   else
      #     yield entity
      #   end
      # end
    end

    def count
      service.execute("#{name}/$count").body.to_i
    end

    private

    def service
      @service ||= OData::ServiceRegistry[namespace]
    end
  end
end