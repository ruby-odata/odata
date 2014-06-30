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
      total, entities = get_paginated_entities(per_page, page)

      while counter <= total
        if counter % per_page == 0
          _, entities = get_paginated_entities(per_page, page += 1)
        end

        block_given? ? block.call(entities[position]) : yield(entities[position])
        counter += 1

        (entities[position] == entities.last) ? position = 0 : position += 1
      end
    end

    # Returns the number of entities within the set
    def count
      service.execute("#{name}/$count").body.to_i
    end

    private

    def service
      @service ||= OData::ServiceRegistry[namespace]
    end

    def get_paginated_entities(per_page, page)
      result = service.execute("#{name}?$inlinecount=allpages&$skip=#{per_page * page}&$top=#{per_page}")
      entities = service.find_entities(result)
      total = service.find_node(result, 'count').content.to_i
      return total, entities
    end
  end
end