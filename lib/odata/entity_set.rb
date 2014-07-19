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

        entity = OData::Entity.from_xml(entities[page_position], entity_options)
        block_given? ? block.call(entity) : yield(entity)

        counter += 1
        page_position += 1
      end
    end

    # Return the first Entity for the set.
    # @return [OData::EntitySet]
    def first
      query = OData::Query.new(self).limit(1)
      result = service.execute(query)
      entities = service.find_entities(result)
      OData::Entity.from_xml(entities[0], entity_options)
    end

    # Returns the number of entities within the set.
    # @return [Integer]
    def count
      service.execute("#{name}/$count").body.to_i
    end

    # Create a new Entity for this set with the given properties.
    # @param properties [Hash] property name as key and it's initial value
    # @return [OData::Entity]
    def new_entity(properties = {})
      OData::Entity.with_properties(properties, entity_options)
    end

    # Find Entities with the supplied filter applied.
    # @param filter [to_s] filter to apply
    # @return [Array<OData::Entity>]
    def filter(filter)
      entities = []
      result = service.execute("#{name}?$filter=#{filter}")

      service.find_entities(result).each do |entity_xml|
        entities << OData::Entity.from_xml(entity_xml, entity_options)
      end

      entities
    end

    # Find the Entity with the supplied key value.
    # @param key [to_s] primary key to lookup
    # @return [OData::Entity,nil]
    def [](key)
      result = service.execute("#{name}(#{key})")
      entities = service.find_entities(result)
      OData::Entity.from_xml(entities[0], entity_options)
    end

    # Write supplied entity back to the service.
    # @param entity [OData::Entity] entity to save or update in the service
    # @return [OData::Entity]
    def <<(entity)
      new_entity = entity[entity.primary_key].nil?

      url_chunk = name
      url_chunk += "(#{entity[entity.primary_key]})" unless new_entity

      options = {
          method: :post,
          body:   entity.to_xml.gsub(/\n\s+/, ''),
          headers: {
              'Accept'       => 'application/atom+xml',
              'Content-Type' => 'application/atom+xml'
          }
      }

      result = service.execute(url_chunk, options)
      if result.code.to_s =~ /^2[0-9][0-9]$/
        if new_entity
          doc = ::Nokogiri::XML(result.body).remove_namespaces!
          entity[entity.primary_key] = doc.xpath("//content/properties/#{entity.primary_key}").first.content
        end
      else
        raise StandardError, 'Something went wrong committing your entity'
      end
      entity
    end

    private

    def service
      @service ||= OData::ServiceRegistry[namespace]
    end

    def entity_options
      {
          namespace:  namespace,
          type:       type
      }
    end

    def get_paginated_entities(per_page, page)
      query = OData::Query.new(self)
      query.include_count.skip(per_page * page).limit(per_page)
      result = service.execute(query)
      entities = service.find_entities(result)
      total = service.find_node(result, 'count').content.to_i
      return total, entities
    end
  end
end