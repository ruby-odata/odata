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
      per_page = 5; page = 0; position = 0; counter = 1
      result = service.execute("#{name}?$inlinecount=allpages&$skip=0&$top=5")
      total = service.find_node(result, 'count').content.to_i

      while counter <= total
        if counter % per_page == 0
          page += 1
          result = service.execute("#{name}?$skip=#{per_page * page}&$top=#{per_page}")
        end

        entities = service.find_entities(result)

        if block_given?
          block.call entities[position]
        else
          yield entities[position]
        end
        counter += 1

        if entities[position] == entities.last
          position = 0
        else
          position += 1
        end
      end
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