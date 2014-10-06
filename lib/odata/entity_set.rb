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

    # The name of the EntitySet
    attr_reader :name
    # The Entity type for the EntitySet
    attr_reader :type
    # The OData::Service's namespace
    attr_reader :namespace
    # The OData::Service's identifiable name
    attr_reader :service_name
    # The EntitySet's container name
    attr_reader :container

    # Sets up the EntitySet to permit querying for the resources in the set.
    #
    # @param options [Hash] the options to setup the EntitySet
    # @return [OData::EntitySet] an instance of the EntitySet
    def initialize(options = {})
      @name         = options[:name]
      @type         = options[:type]
      @namespace    = options[:namespace]
      @service_name = options[:service_name]
      @container    = options[:container]
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

    # Returns a query targetted at the current EntitySet.
    # @return [OData::Query]
    def query
      OData::Query.new(self)
    end

    # Find the Entity with the supplied key value.
    # @param key [to_s] primary key to lookup
    # @return [OData::Entity,nil]
    def [](key)
      entity = new_entity
      key_property = entity.send(:properties)[entity.primary_key]
      key_property.value = key
      url_key = key_property.url_value

      result = service.execute("#{name}(#{url_key})")
      entities = service.find_entities(result)
      OData::Entity.from_xml(entities[0], entity_options)
    end

    # Write supplied entity back to the service.
    # @param entity [OData::Entity] entity to save or update in the service
    # @return [OData::Entity]
    def <<(entity)
      url_chunk, options = setup_entity_post_request(entity)
      result = execute_entity_post_request(options, url_chunk)
      if entity.is_new?
        doc = ::Nokogiri::XML(result).remove_namespaces!
        entity[entity.primary_key] = doc.xpath("//content/properties/#{entity.primary_key}").first.content
      end
      entity
    end

    # The OData::Service this EntitySet is associated with.
    # @return [OData::Service]
    # @api private
    def service
      @service ||= OData::ServiceRegistry[service_name]
    end

    # Options used for instantiating a new OData::Entity for this set.
    # @return [Hash]
    # @api private
    def entity_options
      {
          namespace:    namespace,
          service_name: service_name,
          type:         type
      }
    end

    private

    def get_paginated_entities(per_page, page)
      query = OData::Query.new(self)
      query.include_count.skip(per_page * page).limit(per_page)
      result = service.execute(query)
      entities = service.find_entities(result)
      total = service.find_node(result, 'count').content.to_i
      return total, entities
    end

    def execute_entity_post_request(options, url_chunk)
      result = service.execute(url_chunk, options)
      unless result.code.to_s =~ /^2[0-9][0-9]$/
        raise StandardError, 'Something went wrong committing your entity'
      end
      result.body
    end

    def setup_entity_post_request(entity)
      primary_key = entity.send(:properties)[entity.primary_key].url_value
      chunk = entity.is_new? ? name : "#{name}(#{primary_key})"
      options = {
          method: :post,
          body: entity.to_xml.gsub(/\n\s+/, ''),
          headers: {
              'Accept' => 'application/atom+xml',
              'Content-Type' => 'application/atom+xml'
          }
      }
      return chunk, options
    end
  end
end