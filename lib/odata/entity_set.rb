module OData
  # This class represents a set of entities within an OData service. It is
  # instantiated whenever an OData::Service is asked for an EntitySet via the
  # OData::Service#[] method call. It also provides Enumerable behavior so that
  # you can interact with the entities within a set in a very comfortable way.
  #
  # This class also implements a query interface for finding certain entities
  # based on query criteria or limiting the result set returned by the set. This
  # functionality is implemented through transparent proxy objects.
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
    #
    # @param block [block] a block to evaluate
    # @return [OData::Entity] each entity in turn from this set
    def each(&block)
      per_page = 5; page = 0; page_position = 0; counter = 0
      total, entities = get_paginated_entities(per_page, page)

      until counter == total
        if page_position >= per_page
          page += 1
          _, entities = get_paginated_entities(per_page, page)
          page_position = 0
        end

        entity = OData::Entity.from_xml(entities[page_position], namespace: namespace, type: type)
        block_given? ? block.call(entity) : yield(entity)

        counter += 1
        page_position += 1
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